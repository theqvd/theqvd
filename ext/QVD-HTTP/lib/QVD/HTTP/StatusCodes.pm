package QVD::HTTP::StatusCodes;

use strict;
use warnings;

our $VERSION = '0.01';

# Extracted from Wikipedia
# http://en.wikipedia.org/wiki/List_of_HTTP_status_codes

my $codes = <<'EOC';
100 Continue
    This means that the server has received the request headers, and
    that the client should proceed to send the request body (in the
    case of a request for which a body needs to be sent; for example,
    a POST request). If the request body is large, sending it to a
    server when a request has already been rejected based upon
    inappropriate headers is inefficient. To have a server check if
    the request could be accepted based on the request's headers
    alone, a client must send Expect: 100-continue as a header in its
    initial request (see RFC 2616 §14.20 - Expect header) and check if
    a 100 Continue status code is received in response before
    continuing (or receive 417 Expectation Failed and not
    continue).[2]

101 Switching Protocols
    This means the requester has asked the server to switch protocols
    and the server is acknowledging that it will do so.[3]

102 Processing (WebDAV) (RFC 2518 )

200 OK
    Standard response for successful HTTP requests. The actual
    response will depend on the request method used. In a GET request,
    the response will contain an entity corresponding to the requested
    resource. In a POST request the response will contain an entity
    describing or containing the result of the action.

201 Created
    The request has been fulfilled and resulted in a new resource
    being created.

202 Accepted
    The request has been accepted for processing, but the processing
    has not been completed. The request might or might not eventually
    be acted upon, as it might be disallowed when processing actually
    takes place.

203 Non-Authoritative Information (since HTTP/1.1)
    The server successfully processed the request, but is returning
    information that may be from another source.

204 No Content
    The server successfully processed the request, but is not
    returning any content.

205 Reset Content
    The server successfully processed the request, but is not
    returning any content. Unlike a 204 response, this response
    requires that the requester reset the document view.

206 Partial Content
    The server is delivering only part of the resource due to a range
    header sent by the client. This is used by tools like wget to
    enable resuming of interrupted downloads, or split a download into
    multiple simultaneous streams.

207 Multi-Status (WebDAV) (RFC 2518 )
    The message body that follows is an XML message and can contain a
    number of separate response codes, depending on how many
    sub-requests were made.

300 Multiple Choices
    Indicates multiple options for the resource that the client may
    follow. It, for instance, could be used to present different
    format options for video, list files with different extensions, or
    word sense disambiguation.

301 Moved Permanently
    This and all future requests should be directed to the given URI.

302 Found
    This is the most popular redirect code[citation needed], but also
    an example of industrial practice contradicting the
    standard. HTTP/1.0 specification (RFC 1945 ) required the client
    to perform a temporary redirect (the original describing phrase
    was "Moved Temporarily"), but popular browsers implemented it as a
    303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307
    to distinguish between the two behaviours. However, the majority
    of Web applications and frameworks still use the 302 status code
    as if it were the 303.

303 See Other (since HTTP/1.1)
    The response to the request can be found under another URI using a
    GET method. When received in response to a PUT, it should be
    assumed that the server has received the data and the redirect
    should be issued with a separate GET message.

304 Not Modified
    Indicates the resource has not been modified since last
    requested. Typically, the HTTP client provides a header like the
    If-Modified-Since header to provide a time against which to
    compare. Utilizing this saves bandwidth and reprocessing on both
    the server and client, as only the header data must be sent and
    received in comparison to the entirety of the page being
    re-processed by the server, then resent using more bandwidth of
    the server and client.

305 Use Proxy (since HTTP/1.1)
    Many HTTP clients (such as Mozilla[4] and Internet Explorer) do
    not correctly handle responses with this status code, primarily
    for security reasons.

306 Switch Proxy
    No longer used.

307 Temporary Redirect (since HTTP/1.1)
    In this occasion, the request should be repeated with another URI,
    but future requests can still use the original URI. In contrast to
    303, the request method should not be changed when reissuing the
    original request. For instance, a POST request must be repeated
    using another POST request.

400 Bad Request
    The request contains bad syntax or cannot be fulfilled.

401 Unauthorized
    Similar to 403 Forbidden, but specifically for use when
    authentication is possible but has failed or not yet been
    provided. The response must include a WWW-Authenticate header
    field containing a challenge applicable to the requested
    resource. See Basic access authentication and Digest access
    authentication.

402 Payment Required
    The original intention was that this code might be used as part of
    some form of digital cash or micropayment scheme, but that has not
    happened, and this code has never been used.

403 Forbidden
    The request was a legal request, but the server is refusing to
    respond to it. Unlike a 401 Unauthorized response, authenticating
    will make no difference.

404 Not Found
    The requested resource could not be found but may be available
    again in the future. Subsequent requests by the client are
    permissible.

405 Method Not Allowed
    A request was made of a resource using a request method not
    supported by that resource; for example, using GET on a form which
    requires data to be presented via POST, or using PUT on a
    read-only resource.

406 Not Acceptable
    The requested resource is only capable of generating content not
    acceptable according to the Accept headers sent in the request.

407 Proxy Authentication Required

408 Request Timeout
    The server timed out waiting for the request.

409 Conflict
    Indicates that the request could not be processed because of
    conflict in the request, such as an edit conflict.

410 Gone
    Indicates that the resource requested is no longer available and
    will not be available again. This should be used when a resource
    has been intentionally removed; however, it is not necessary to
    return this code and a 404 Not Found can be issued instead. Upon
    receiving a 410 status code, the client should not request the
    resource again in the future. Clients such as search engines
    should remove the resource from their indexes.

411 Length Required
    The request did not specify the length of its content, which is
    required by the requested resource.

412 Precondition Failed
    The server does not meet one of the preconditions that the
    requester put on the request.

413 Request Entity Too Large
    The request is larger than the server is willing or able to
    process.

414 Request-URI Too Long
    The URI provided was too long for the server to process.

415 Unsupported Media Type
    The request did not specify any media types that the server or
    resource supports. For example the client specified that an image
    resource should be served as image/svg+xml, but the server cannot
    find a matching version of the image.

416 Requested Range Not Satisfiable
    The client has asked for a portion of the file, but the server
    cannot supply that portion (for example, if the client asked for a
    part of the file that lies beyond the end of the file).

417 Expectation Failed
    The server cannot meet the requirements of the Expect
    request-header field.

422 Unprocessable Entity (WebDAV) (RFC 4918 )
    The request was well-formed but was unable to be followed due to
    semantic errors.

423 Locked (WebDAV) (RFC 4918 )
    The resource that is being accessed is locked

424 Failed Dependency (WebDAV) (RFC 4918 )
    The request failed due to failure of a previous request (e.g. a
    PROPPATCH).

425 Unordered Collection
    Defined in drafts of WebDav Advanced Collections, but not present
    in "Web Distributed Authoring and Versioning (WebDAV) Ordered
    Collections Protocol" (RFC 3648 ).

426 Upgrade Required (RFC 2817 )
    The client should switch to some specific protocol.

449 Retry With

500 Internal Server Error
    A generic error message, given when no more specific message is
    suitable.

501 Not Implemented
    The server either does not recognise the request method, or it
    lacks the ability to fulfil the request.

502 Bad Gateway
    The server was acting as a gateway or proxy and received an
    invalid response from the downstream server.

503 Service Unavailable
    The server is currently unavailable (because it is overloaded or
    down for maintenance). Generally, this is a temporary state.

504 Gateway Timeout
    The server was acting as a gateway or proxy and did not receive a
    timely request from the downstream server.

505 HTTP Version Not Supported
    The server does not support the HTTP protocol version used in the
    request.

506 Variant Also Negotiates (RFC 2295 )
    Transparent content negotiation for the request, results in a
    circular reference.

507 Insufficient Storage (WebDAV) (RFC 4918 )

509 Bandwidth Limit Exceeded (Apache bw/limited extension)
    This status code, while used by many servers, is not specified in
    any RFCs.

510 Not Extended (RFC 2774 )
    Further extensions to the request are required for the server to
    fulfil it.

651 HTTP Version Not Supported By Client
    The client does not the HTTP protocol version used in the response

652 Bad Response
    The response contains bad syntax

EOC

use Scalar::Util qw(dualvar);

my %desc;
my %msg;

my @status_codes;

for (split "\n\n", $codes) {
    s/(?:\r?\n)*$/\n/;
    if (my ($code, $msg) = /^(\d+)\s+(.*?)\s*(?:\(.*)?(?:$)/m) {
	my $name = uc "HTTP_$msg";
	$name =~ tr/- /__/;
	$name =~ s/^HTTP_HTTP_/HTTP_/;
	# print "code: $code, name: $name, msg: $msg\n";
	push @status_codes, $name;
	my $value = dualvar $code, "$code $msg";
	$desc{$code} = $_;
	$msg{$code} = $msg;
	no strict qw(refs);
	*$name = sub () { $value };
    }
    else {
	die "bad status code description\n>>>$_<<<\n\n";
    }
}

sub http_status_message {
    my $code = int shift;
    $msg{$code} ||= "$code Unknown error"
}

sub http_status_description {
    my $code = int shift;
    $desc{$code} ||= "$code Unknown status code"
}

use parent qw(Exporter);

our @EXPORT_OK = (qw(http_status_description
		     http_status_message),
		  @status_codes);
our %EXPORT_TAGS = (status_codes => [@status_codes],
		    all => [@EXPORT_OK]);

1;
__END__

=head1 NAME

QVD::HTTP - The great new QVD::HTTP::StatusCodes!

=head1 SYNOPSIS

Quick summary of what the module does.

    use QVD::HTTP::StatusCodes qw(:status_codes);

    $httpd->send_response(HTTP_OK, \@headers, $text);


=head1 FUNCTIONS

=over 4

=item http_status_message($code)

returns the short status message for the given HTTP response code.

=item http_status_description($code)

returns a full description of the given HTTP response code.

=item HTTP_OK

=item HTTP_INTERNAL_SERVER_ERROR

...

=back

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-http at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-HTTP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
