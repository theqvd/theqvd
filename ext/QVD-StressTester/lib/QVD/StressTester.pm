package QVD::StressTester;

# This is a hacked version of AnyEvent::HTTP

use common::sense;

use Errno ();

use AnyEvent 5.0 ();
use AnyEvent::Util ();
use AnyEvent::Handle ();

use base Exporter;

our $VERSION = 2.22;

our @EXPORT = qw(http_get http_post http_head http_request);

our $USERAGENT          = "Mozilla/5.0 (compatible; U; AnyEvent-HTTP/$VERSION; +http://software.schmorp.de/pkg/AnyEvent)";
our $MAX_RECURSE        =  10;
our $PERSISTENT_TIMEOUT =   3;
our $TIMEOUT            = 300;
our $MAX_PER_HOST       =   4; # changing this is evil

our $PROXY;
our $ACTIVE = 0;

my %KA_CACHE; # indexed by uhost currently, points to [$handle...] array
my %CO_SLOT;  # number of open connections, and wait queue, per host


#############################################################################
# wait queue/slots

sub _slot_schedule;
sub _slot_schedule($) {
   my $host = shift;

   while ($CO_SLOT{$host}[0] < $MAX_PER_HOST) {
      if (my $cb = shift @{ $CO_SLOT{$host}[1] }) {
         # somebody wants that slot
         ++$CO_SLOT{$host}[0];
         ++$ACTIVE;

         $cb->(AnyEvent::Util::guard {
            --$ACTIVE;
            --$CO_SLOT{$host}[0];
            _slot_schedule $host;
         });
      } else {
         # nobody wants the slot, maybe we can forget about it
         delete $CO_SLOT{$host} unless $CO_SLOT{$host}[0];
         last;
      }
   }
}

# wait for a free slot on host, call callback
sub _get_slot($$) {
   push @{ $CO_SLOT{$_[0]}[1] }, $_[1];

   _slot_schedule $_[0];
}

#############################################################################
# cookie handling

# expire cookies
sub cookie_jar_expire($;$) {
   my ($jar, $session_end) = @_;

   %$jar = () if $jar->{version} != 1;

   my $anow = AE::now;

   while (my ($chost, $paths) = each %$jar) {
      next unless ref $paths;

      while (my ($cpath, $cookies) = each %$paths) {
         while (my ($cookie, $kv) = each %$cookies) {
            if (exists $kv->{_expires}) {
               delete $cookies->{$cookie}
                  if $anow > $kv->{_expires};
            } elsif ($session_end) {
               delete $cookies->{$cookie};
            }
         }

         delete $paths->{$cpath}
            unless %$cookies;
      }

      delete $jar->{$chost}
         unless %$paths;
   }
}
 
# extract cookies from jar
sub cookie_jar_extract($$$$) {
   my ($jar, $scheme, $host, $path) = @_;

   %$jar = () if $jar->{version} != 1;

   my @cookies;

   while (my ($chost, $paths) = each %$jar) {
      next unless ref $paths;

      if ($chost =~ /^\./) {
         next unless $chost eq substr $host, -length $chost;
      } elsif ($chost =~ /\./) {
         next unless $chost eq $host;
      } else {
         next;
      }

      while (my ($cpath, $cookies) = each %$paths) {
         next unless $cpath eq substr $path, 0, length $cpath;

         while (my ($cookie, $kv) = each %$cookies) {
            next if $scheme ne "https" && exists $kv->{secure};

            if (exists $kv->{_expires} and AE::now > $kv->{_expires}) {
               delete $cookies->{$cookie};
               next;
            }

            my $value = $kv->{value};

            if ($value =~ /[=;,[:space:]]/) {
               $value =~ s/([\\"])/\\$1/g;
               $value = "\"$value\"";
            }

            push @cookies, "$cookie=$value";
         }
      }
   }

   \@cookies
}
 
# parse set_cookie header into jar
sub cookie_jar_set_cookie($$$$) {
   my ($jar, $set_cookie, $host, $date) = @_;

   my $anow = int AE::now;
   my $snow; # server-now

   for ($set_cookie) {
      # parse NAME=VALUE
      my @kv;

      # expires is not http-compliant in the original cookie-spec,
      # we support the official date format and some extensions
      while (
         m{
            \G\s*
            (?:
               expires \s*=\s* ([A-Z][a-z][a-z]+,\ [^,;]+)
               | ([^=;,[:space:]]+) (?: \s*=\s* (?: "((?:[^\\"]+|\\.)*)" | ([^;,[:space:]]*) ) )?
            )
         }gcxsi
      ) {
         my $name = $2;
         my $value = $4;

         if (defined $1) {
            # expires
            $name  = "expires";
            $value = $1;
         } elsif (defined $3) {
            # quoted
            $value = $3;
            $value =~ s/\\(.)/$1/gs;
         }

         push @kv, @kv ? lc $name : $name, $value;

         last unless /\G\s*;/gc;
      }

      last unless @kv;

      my $name = shift @kv;
      my %kv = (value => shift @kv, @kv);

      if (exists $kv{"max-age"}) {
         $kv{_expires} = $anow + delete $kv{"max-age"};
      } elsif (exists $kv{expires}) {
         $snow ||= parse_date ($date) || $anow;
         $kv{_expires} = $anow + (parse_date (delete $kv{expires}) - $snow);
      } else {
         delete $kv{_expires};
      }

      my $cdom;
      my $cpath = (delete $kv{path}) || "/";

      if (exists $kv{domain}) {
         $cdom = delete $kv{domain};

         $cdom =~ s/^\.?/./; # make sure it starts with a "."

         next if $cdom =~ /\.$/;

         # this is not rfc-like and not netscape-like. go figure.
         my $ndots = $cdom =~ y/.//;
         next if $ndots < ($cdom =~ /\.[^.][^.]\.[^.][^.]$/ ? 3 : 2);
      } else {
         $cdom = $host;
      }

      # store it
      $jar->{version} = 1;
      $jar->{lc $cdom}{$cpath}{$name} = \%kv;

      redo if /\G\s*,/gc;
   }
}

#############################################################################
# keepalive/persistent connection cache

# fetch a connection from the keepalive cache
sub ka_fetch($) {
   my $ka_key = shift;

   my $hdl = pop @{ $KA_CACHE{$ka_key} }; # currently we reuse the MOST RECENTLY USED connection
   delete $KA_CACHE{$ka_key}
      unless @{ $KA_CACHE{$ka_key} };

   $hdl
}

sub ka_store($$) {
   my ($ka_key, $hdl) = @_;

   my $kaa = $KA_CACHE{$ka_key} ||= [];

   my $destroy = sub {
      my @ka = grep $_ != $hdl, @{ $KA_CACHE{$ka_key} };

      $hdl->destroy;

      @ka
         ? $KA_CACHE{$ka_key} = \@ka
         : delete $KA_CACHE{$ka_key};
   };

   # on error etc., destroy
   $hdl->on_error ($destroy);
   $hdl->on_eof   ($destroy);
   $hdl->on_read  ($destroy);
   $hdl->timeout  ($PERSISTENT_TIMEOUT);

   push @$kaa, $hdl;
   shift @$kaa while @$kaa > $MAX_PER_HOST;
}

#############################################################################
# utilities

# continue to parse $_ for headers and place them into the arg
sub _parse_hdr() {
   my %hdr;

   # things seen, not parsed:
   # p3pP="NON CUR OTPi OUR NOR UNI"

   $hdr{lc $1} .= ",$2"
      while /\G
            ([^:\000-\037]*):
            [\011\040]*
            ((?: [^\012]+ | \012[\011\040] )*)
            \012
         /gxc;

   /\G$/
     or return;

   # remove the "," prefix we added to all headers above
   substr $_, 0, 1, ""
      for values %hdr;

   \%hdr
}

#############################################################################
# http_get

our $qr_nlnl = qr{(?<![^\012])\015?\012};

our $TLS_CTX_LOW  = { cache => 1, sslv2 => 1 };
our $TLS_CTX_HIGH = { cache => 1, verify => 1, verify_peername => "https" };

# maybe it should just become a normal object :/

sub _destroy_state(\%) {
   my ($state) = @_;

   $state->{handle}->destroy if $state->{handle};
   %$state = ();
}

sub _error(\%$$) {
   my ($state, $cb, $hdr) = @_;

   &_destroy_state ($state);

   $cb->(undef, $hdr);
   ()
}

our %IDEMPOTENT = (
   DELETE		=> 1,
   GET			=> 1,
   HEAD			=> 1,
   OPTIONS		=> 1,
   PUT			=> 1,
   TRACE		=> 1,

   ACL			=> 1,
   "BASELINE-CONTROL"	=> 1,
   BIND			=> 1,
   CHECKIN		=> 1,
   CHECKOUT		=> 1,
   COPY			=> 1,
   LABEL		=> 1,
   LINK			=> 1,
   MERGE		=> 1,
   MKACTIVITY		=> 1,
   MKCALENDAR		=> 1,
   MKCOL		=> 1,
   MKREDIRECTREF	=> 1,
   MKWORKSPACE		=> 1,
   MOVE			=> 1,
   ORDERPATCH		=> 1,
   PROPFIND		=> 1,
   PROPPATCH		=> 1,
   REBIND		=> 1,
   REPORT		=> 1,
   SEARCH		=> 1,
   UNBIND		=> 1,
   UNCHECKOUT		=> 1,
   UNLINK		=> 1,
   UNLOCK		=> 1,
   UPDATE		=> 1,
   UPDATEREDIRECTREF	=> 1,
   "VERSION-CONTROL"	=> 1,
);

sub http_request($$@) {
   my $cb = pop;
   my ($method, $url, %arg) = @_;

   my %hdr;

   $arg{tls_ctx} = $TLS_CTX_LOW  if $arg{tls_ctx} eq "low" || !exists $arg{tls_ctx};
   $arg{tls_ctx} = $TLS_CTX_HIGH if $arg{tls_ctx} eq "high";

   $method = uc $method;

   if (my $hdr = $arg{headers}) {
      while (my ($k, $v) = each %$hdr) {
         $hdr{lc $k} = $v;
      }
   }

   # pseudo headers for all subsequent responses
   my @pseudo = (URL => $url);
   push @pseudo, Redirect => delete $arg{Redirect} if exists $arg{Redirect};

   my $recurse = exists $arg{recurse} ? delete $arg{recurse} : $MAX_RECURSE;

   return $cb->(undef, { @pseudo, Status => 599, Reason => "Too many redirections" })
      if $recurse < 0;

   my $proxy   = exists $arg{proxy} ? $arg{proxy} : $PROXY;
   my $timeout = $arg{timeout} || $TIMEOUT;

   my ($uscheme, $uauthority, $upath, $query, undef) = # ignore fragment
      $url =~ m|^([^:]+):(?://([^/?#]*))?([^?#]*)(?:(\?[^#]*))?(?:#(.*))?$|;

   $uscheme = lc $uscheme;

   my $uport = $uscheme eq "http"  ?  80
             : $uscheme eq "https" ? 443
             : return $cb->(undef, { @pseudo, Status => 599, Reason => "Only http and https URL schemes supported" });

   $uauthority =~ /^(?: .*\@ )? ([^\@]+?) (?: : (\d+) )?$/x
      or return $cb->(undef, { @pseudo, Status => 599, Reason => "Unparsable URL" });

   my $uhost = lc $1;
   $uport = $2 if defined $2;

   $hdr{host} = defined $2 ? "$uhost:$2" : "$uhost"
      unless exists $hdr{host};

   $uhost =~ s/^\[(.*)\]$/$1/;
   $upath .= $query if length $query;

   $upath =~ s%^/?%/%;

   # cookie processing
   if (my $jar = $arg{cookie_jar}) {
      my $cookies = cookie_jar_extract $jar, $uscheme, $uhost, $upath;

      $hdr{cookie} = join "; ", @$cookies
         if @$cookies;
   }

   my ($rhost, $rport, $rscheme, $rpath); # request host, port, path

   if ($proxy) {
      ($rpath, $rhost, $rport, $rscheme) = ($url, @$proxy);

      $rscheme = "http" unless defined $rscheme;

      # don't support https requests over https-proxy transport,
      # can't be done with tls as spec'ed, unless you double-encrypt.
      $rscheme = "http" if $uscheme eq "https" && $rscheme eq "https";

      $rhost   = lc $rhost;
      $rscheme = lc $rscheme;
   } else {
      ($rhost, $rport, $rscheme, $rpath) = ($uhost, $uport, $uscheme, $upath);
   }

   # leave out fragment and query string, just a heuristic
   $hdr{referer}      = "$uscheme://$uauthority$upath" unless exists $hdr{referer};
   $hdr{"user-agent"} = $USERAGENT                     unless exists $hdr{"user-agent"};

   $hdr{"content-length"} = length $arg{body}
      if length $arg{body} || $method ne "GET";

   my $idempotent = $IDEMPOTENT{$method};

   # default value for keepalive is true iff the request is for an idempotent method
   my $persistent = exists $arg{persistent} ? !!$arg{persistent} : $idempotent;
   my $keepalive  = exists $arg{keepalive}  ? !!$arg{keepalive}  : !$proxy;
   my $was_persistent; # true if this is actually a recycled connection

   # the key to use in the keepalive cache
   my $ka_key = "$uscheme\x00$uhost\x00$uport\x00$arg{sessionid}";

   $hdr{connection} //= ($persistent ? $keepalive ? "keep-alive, " : "" : "close, ") . "Te"; #1.1
   $hdr{te}         = "trailers" unless exists $hdr{te}; #1.1

   my %state = (connect_guard => 1);

   my $ae_error = 595; # connecting

   # handle actual, non-tunneled, request
   my $handle_actual_request = sub {
      $ae_error = 596; # request phase

      my $hdl = $state{handle};

      $hdl->starttls ("connect") if $uscheme eq "https" && !exists $hdl->{tls};

      # send request
      $hdl->push_write (
         "$method $rpath HTTP/1.1\015\012"
         . (join "", map "\u$_: $hdr{$_}\015\012", grep defined $hdr{$_}, keys %hdr)
         . "\015\012"
         . $arg{body}
      );

      # return if error occurred during push_write()
      return unless %state;

      # reduce memory usage, save a kitten, also re-use it for the response headers.
      %hdr = ();

      # status line and headers
      $state{read_response} = sub {
         return unless %state;

         for ("$_[1]") {
            y/\015//d; # weed out any \015, as they show up in the weirdest of places.

            /^HTTP\/0*([0-9\.]+) \s+ ([0-9]{3}) (?: \s+ ([^\012]*) )? \012/gxci
               or return _error %state, $cb, { @pseudo, Status => 599, Reason => "Invalid server response" };

            # 100 Continue handling
            # should not happen as we don't send expect: 100-continue,
            # but we handle it just in case.
            # since we send the request body regardless, if we get an error
            # we are out of-sync, which we currently do NOT handle correctly.
            if ($2 == 100 or $2 == 102) {
                # warn "$_[1]";
                return $state{handle}->push_read (line => $qr_nlnl, $state{read_response})
            }


            push @pseudo,
               HTTPVersion => $1,
               Status      => $2,
               Reason      => $3,
            ;

            my $hdr = _parse_hdr
               or return _error %state, $cb, { @pseudo, Status => 599, Reason => "Garbled response headers" };

            %hdr = (%$hdr, @pseudo);
         }

         # redirect handling
         # relative uri handling forced by microsoft and other shitheads.
         # we give our best and fall back to URI if available.
         if (exists $hdr{location}) {
            my $loc = $hdr{location};

            if ($loc =~ m%^//%) { # //
               $loc = "$rscheme:$loc";

            } elsif ($loc eq "") {
               $loc = $url;

            } elsif ($loc !~ /^(?: $ | [^:\/?\#]+ : )/x) { # anything "simple"
               $loc =~ s/^\.\/+//;

               if ($loc !~ m%^[.?#]%) {
                  my $prefix = "$rscheme://$uhost:$uport";

                  unless ($loc =~ s/^\///) {
                     $prefix .= $upath;
                     $prefix =~ s/\/[^\/]*$//;
                  }

                  $loc = "$prefix/$loc";

               } elsif (eval { require URI }) { # uri
                  $loc = URI->new_abs ($loc, $url)->as_string;

               } else {
                  return _error %state, $cb, { @pseudo, Status => 599, Reason => "Cannot parse Location (URI module missing)" };
                  #$hdr{Status} = 599;
                  #$hdr{Reason} = "Unparsable Redirect (URI module missing)";
                  #$recurse = 0;
               }
            }

            $hdr{location} = $loc;
         }

         my $redirect;

         if ($recurse) {
            my $status = $hdr{Status};

            # industry standard is to redirect POST as GET for
            # 301, 302 and 303, in contrast to HTTP/1.0 and 1.1.
            # also, the UA should ask the user for 301 and 307 and POST,
            # industry standard seems to be to simply follow.
            # we go with the industry standard. 308 is defined
            # by rfc7538
            if ($status == 301 or $status == 302 or $status == 303) {
               $redirect = 1;
               # HTTP/1.1 is unclear on how to mutate the method
               unless ($method eq "HEAD") {
                  $method = "GET";
                  delete $arg{body};
               }
            } elsif ($status == 307 or $status == 308) {
               $redirect = 1;
            }
         }

         my $finish = sub { # ($data, $err_status, $err_reason[, $persistent])
            if ($state{handle}) {
               # handle keepalive
               if (
                  $persistent
                  && $_[3]
                  && ($hdr{HTTPVersion} < 1.1
                      ? $hdr{connection} =~ /\b(?:keep-?alive|upgrade)\b/i
                      : $hdr{connection} !~ /\bclose\b/i)
               ) {
                  ka_store $ka_key, delete $state{handle};
               } else {
                  # no keepalive, destroy the handle
                  $state{handle}->destroy;
               }
            }

            %state = ();

            if (defined $_[1]) {
               $hdr{OrigStatus} = $hdr{Status}; $hdr{Status} = $_[1];
               $hdr{OrigReason} = $hdr{Reason}; $hdr{Reason} = $_[2];
            }

            # set-cookie processing
            if ($arg{cookie_jar}) {
               cookie_jar_set_cookie $arg{cookie_jar}, $hdr{"set-cookie"}, $uhost, $hdr{date};
            }

            if ($redirect && exists $hdr{location}) {
               # we ignore any errors, as it is very common to receive
               # Content-Length != 0 but no actual body
               # we also access %hdr, as $_[1] might be an erro
               $state{recurse} =
                  http_request (
                     $method  => $hdr{location},
                     %arg,
                     recurse  => $recurse - 1,
                     Redirect => [$_[0], \%hdr],
                     sub {
                        %state = ();
                        &$cb
                     },
                  );
            } else {
               $cb->($_[0], \%hdr);
            }
         };

         $ae_error = 597; # body phase

         my $chunked = $hdr{"transfer-encoding"} =~ /\bchunked\b/i; # not quite correct...

         my $len = $chunked ? undef : $hdr{"content-length"};

         # body handling, many different code paths
         # - no body expected
         # - want_body_handle
         # - te chunked
         # - 2x length known (with or without on_body)
         # - 2x length not known (with or without on_body)
         if (!$redirect && $arg{on_header} && !$arg{on_header}(\%hdr)) {
            $finish->(undef, 598 => "Request cancelled by on_header");
         } elsif (
            $hdr{Status} =~ /^(?:1..|204|205|304)$/
            or $method eq "HEAD"
            or (defined $len && $len == 0) # == 0, not !, because "0   " is true
         ) {
            # no body
            $finish->("", undef, undef, 1);

         } elsif (!$redirect && $arg{want_body_handle}) {
            $_[0]->on_eof   (undef);
            $_[0]->on_error (undef);
            $_[0]->on_read  (undef);

            $finish->(delete $state{handle});

         } elsif ($chunked) {
            my $cl = 0;
            my $body = "";
            my $on_body = $arg{on_body} || sub { $body .= shift; 1 };

            $state{read_chunk} = sub {
               $_[1] =~ /^([0-9a-fA-F]+)/
                  or return $finish->(undef, $ae_error => "Garbled chunked transfer encoding");

               my $len = hex $1;

               if ($len) {
                  $cl += $len;

                  $_[0]->push_read (chunk => $len, sub {
                     $on_body->($_[1], \%hdr)
                        or return $finish->(undef, 598 => "Request cancelled by on_body");

                     $_[0]->push_read (line => sub {
                        length $_[1]
                           and return $finish->(undef, $ae_error => "Garbled chunked transfer encoding");
                        $_[0]->push_read (line => $state{read_chunk});
                     });
                  });
               } else {
                  $hdr{"content-length"} ||= $cl;

                  $_[0]->push_read (line => $qr_nlnl, sub {
                     if (length $_[1]) {
                        for ("$_[1]") {
                           y/\015//d; # weed out any \015, as they show up in the weirdest of places.

                           my $hdr = _parse_hdr
                              or return $finish->(undef, $ae_error => "Garbled response trailers");

                           %hdr = (%hdr, %$hdr);
                        }
                     }

                     $finish->($body, undef, undef, 1);
                  });
               }
            };

            $_[0]->push_read (line => $state{read_chunk});

         } elsif ($arg{on_body}) {
            if (defined $len) {
               $_[0]->on_read (sub {
                  $len -= length $_[0]{rbuf};

                  $arg{on_body}(delete $_[0]{rbuf}, \%hdr)
                     or return $finish->(undef, 598 => "Request cancelled by on_body");

                  $len > 0
                     or $finish->("", undef, undef, 1);
               });
            } else {
               $_[0]->on_eof (sub {
                  $finish->("");
               });
               $_[0]->on_read (sub {
                  $arg{on_body}(delete $_[0]{rbuf}, \%hdr)
                     or $finish->(undef, 598 => "Request cancelled by on_body");
               });
            }
         } else {
            $_[0]->on_eof (undef);

            if (defined $len) {
               $_[0]->on_read (sub {
                  $finish->((substr delete $_[0]{rbuf}, 0, $len, ""), undef, undef, 1)
                     if $len <= length $_[0]{rbuf};
               });
            } else {
               $_[0]->on_error (sub {
                  ($! == Errno::EPIPE || !$!)
                     ? $finish->(delete $_[0]{rbuf})
                     : $finish->(undef, $ae_error => $_[2]);
               });
               $_[0]->on_read (sub { });
            }
         }
      };

      # if keepalive is enabled, then the server closing the connection
      # before a response can happen legally - we retry on idempotent methods.
      if ($was_persistent && $idempotent) {
         my $old_eof = $hdl->{on_eof};
         $hdl->{on_eof} = sub {
            _destroy_state %state;

            %state = ();
            $state{recurse} =
               http_request (
                  $method    => $url,
                  %arg,
                  recurse    => $recurse - 1,
                  persistent => 0,
                  sub {
                     %state = ();
                     &$cb
                  }
               );
         };
         $hdl->on_read (sub {
            return unless %state;

            # as soon as we receive something, a connection close
            # once more becomes a hard error
            $hdl->{on_eof} = $old_eof;
            $hdl->push_read (line => $qr_nlnl, $state{read_response});
         });
      } else {
         $hdl->push_read (line => $qr_nlnl, $state{read_response});
      }
   };

   my $prepare_handle = sub {
      my ($hdl) = $state{handle};

      $hdl->on_error (sub {
         _error %state, $cb, { @pseudo, Status => $ae_error, Reason => $_[2] };
      });
      $hdl->on_eof (sub {
         _error %state, $cb, { @pseudo, Status => $ae_error, Reason => "Unexpected end-of-file" };
      });
      $hdl->timeout_reset;
      $hdl->timeout ($timeout);
   };

   # connected to proxy (or origin server)
   my $connect_cb = sub {
      my $fh = shift
         or return _error %state, $cb, { @pseudo, Status => $ae_error, Reason => "$!" };

      return unless delete $state{connect_guard};

      # get handle
      $state{handle} = new AnyEvent::Handle
         %{ $arg{handle_params} },
         fh       => $fh,
         peername => $uhost,
         tls_ctx  => $arg{tls_ctx},
      ;

      $prepare_handle->();

      #$state{handle}->starttls ("connect") if $rscheme eq "https";

      # now handle proxy-CONNECT method
      if ($proxy && $uscheme eq "https") {
         # oh dear, we have to wrap it into a connect request

         my $auth = exists $hdr{"proxy-authorization"}
            ? "proxy-authorization: " . (delete $hdr{"proxy-authorization"}) . "\015\012"
            : "";

         # maybe re-use $uauthority with patched port?
         $state{handle}->push_write ("CONNECT $uhost:$uport HTTP/1.0\015\012$auth\015\012");
         $state{handle}->push_read (line => $qr_nlnl, sub {
            $_[1] =~ /^HTTP\/([0-9\.]+) \s+ ([0-9]{3}) (?: \s+ ([^\015\012]*) )?/ix
               or return _error %state, $cb, { @pseudo, Status => 599, Reason => "Invalid proxy connect response ($_[1])" };

            if ($2 == 200) {
               $rpath = $upath;
               $handle_actual_request->();
            } else {
               _error %state, $cb, { @pseudo, Status => $2, Reason => $3 };
            }
         });
      } else {
         delete $hdr{"proxy-authorization"} unless $proxy;

         $handle_actual_request->();
      }
   };

   _get_slot $uhost, sub {
      $state{slot_guard} = shift;

      return unless $state{connect_guard};

      # try to use an existing keepalive connection, but only if we, ourselves, plan
      # on a keepalive request (in theory, this should be a separate config option).
      if ($persistent && $KA_CACHE{$ka_key}) {
         $was_persistent = 1;

         $state{handle} = ka_fetch $ka_key;
         $state{handle}->destroyed
            and die "AnyEvent::HTTP: unexpectedly got a destructed handle (1), please report.";#d#
         $prepare_handle->();
         $state{handle}->destroyed
            and die "AnyEvent::HTTP: unexpectedly got a destructed handle (2), please report.";#d#
         $handle_actual_request->();

      } else {
         my $tcp_connect = $arg{tcp_connect}
                           || do { require AnyEvent::Socket; \&AnyEvent::Socket::tcp_connect };

         $state{connect_guard} = $tcp_connect->($rhost, $rport, $connect_cb, $arg{on_prepare} || sub { $timeout });
      }
   };

   defined wantarray && AnyEvent::Util::guard { _destroy_state %state }
}

sub http_get($@) {
   unshift @_, "GET";
   &http_request
}

sub http_head($@) {
   unshift @_, "HEAD";
   &http_request
}

sub http_post($$@) {
   my $url = shift;
   unshift @_, "POST", $url, "body";
   &http_request
}

our @month   = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
our @weekday = qw(Sun Mon Tue Wed Thu Fri Sat);

sub format_date($) {
   my ($time) = @_;

   # RFC 822/1123 format
   my ($S, $M, $H, $mday, $mon, $year, $wday, $yday, undef) = gmtime $time;

   sprintf "%s, %02d %s %04d %02d:%02d:%02d GMT",
      $weekday[$wday], $mday, $month[$mon], $year + 1900,
      $H, $M, $S;
}

sub parse_date($) {
   my ($date) = @_;

   my ($d, $m, $y, $H, $M, $S);

   if ($date =~ /^[A-Z][a-z][a-z]+, ([0-9][0-9]?)[\- ]([A-Z][a-z][a-z])[\- ]([0-9][0-9][0-9][0-9]) ([0-9][0-9]?):([0-9][0-9]?):([0-9][0-9]?) GMT$/) {
      # RFC 822/1123, required by RFC 2616 (with " ")
      # cookie dates (with "-")

      ($d, $m, $y, $H, $M, $S) = ($1, $2, $3, $4, $5, $6);

   } elsif ($date =~ /^[A-Z][a-z][a-z]+, ([0-9][0-9]?)-([A-Z][a-z][a-z])-([0-9][0-9]) ([0-9][0-9]?):([0-9][0-9]?):([0-9][0-9]?) GMT$/) {
      # RFC 850
      ($d, $m, $y, $H, $M, $S) = ($1, $2, $3 < 69 ? $3 + 2000 : $3 + 1900, $4, $5, $6);

   } elsif ($date =~ /^[A-Z][a-z][a-z]+ ([A-Z][a-z][a-z]) ([0-9 ]?[0-9]) ([0-9][0-9]?):([0-9][0-9]?):([0-9][0-9]?) ([0-9][0-9][0-9][0-9])$/) {
      # ISO C's asctime
      ($d, $m, $y, $H, $M, $S) = ($2, $1, $6, $3, $4, $5);
   }
   # other formats fail in the loop below

   for (0..11) {
      if ($m eq $month[$_]) {
         require Time::Local;
         return eval { Time::Local::timegm ($S, $M, $H, $d, $_, $y) };
      }
   }

   undef
}

sub set_proxy($) {
   if (length $_[0]) {
      $_[0] =~ m%^(http):// ([^:/]+) (?: : (\d*) )?%ix
         or Carp::croak "$_[0]: invalid proxy URL";
      $PROXY = [$2, $3 || 3128, $1]
   } else {
      undef $PROXY;
   }
}

# initialise proxy from environment
eval {
   set_proxy $ENV{http_proxy};
};

1

