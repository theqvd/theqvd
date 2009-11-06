#!/usr/bin/perl

use strict;
use Wx;

package MyFrame;

use base 'Wx::Frame';
# import the event registration function
use Wx::Event qw(EVT_BUTTON);

sub new {
    my $ref = shift;
    my $self = $ref->SUPER::new( undef,           # parent window
                                 -1,              # ID -1 means any
                                 'QVD',           # title
                                 [-1, -1],        # default position
                                 [310, 190],      # size
                                 );

    my $panel = Wx::Panel->new( $self,            # parent window
                                -1,               # ID
                                );
				  
    my $username = Wx::TextCtrl->new( $panel,     # parent window
                                  -1,             # ID
                                  'qvd',     # label
                                  [20, 20],       # position
                                  [270, -1],      # default size
                                  );
    $self->{username}=$username;
				  
    my $password = Wx::TextCtrl->new( $panel,     # parent window
                                  -1,             # ID
                                  'passw0rd',     # label
                                  [20, 60],       # position
                                  [270, -1],      # default size
                                  );
    $self->{password}=$password;

    my $host = Wx::TextCtrl->new( $panel,         # parent window
                                  -1,             # ID
                                  'aguila',       # label
                                  [20, 100],      # position
                                  [200, -1],      # default size
                                  );
    $self->{host}=$host;
				  
    my $port = Wx::TextCtrl->new( $panel,         # parent window
                                  -1,             # ID
                                  '8080',         # label
                                  [230, 100],     # position
                                  [60, -1],       # default size
                                  );	
    $self->{port}=$port;
				  
    my $button = Wx::Button->new( $panel,         # parent window
                                  -1,             # ID
                                  'Conectar',     # label
                                  [20, 140],      # position
                                  [270, -1],      # default size
                                  );									    
				  
				  

    # register the OnClick method as an handler for the
    # 'button clicked' event. The first argument is a Wx::EvtHandler
    # that receives the event
    EVT_BUTTON( $self, $button, \&OnClick );

    return $self;
}

# this method receives as its first parameter the first argument
# passed to the EVT_BUTTON function. The second parameter
# always is a Wx::Event subclass
sub OnClick {
    my( $self, $event ) = @_;
    @ARGV = ($self->{username}->GetValue, $self->{password}->GetValue, $self->{host}->GetValue, $self->{port}->GetValue);
    do "QVD-Client/bin/qvd-client.pl";
    
    $self->SetTitle($@." | ".$!);
}

package MyApp;

use base 'Wx::App';

sub OnInit {
    my $frame = MyFrame->new;

    $frame->Show( 1 );
}



package main;

my $app = MyApp->new;
$app->MainLoop;

__END__

=head1 NAME

qvd-gui-client.pl

=head1 DESCRIPTION

probe of concept graphic client for the new QVD

=cut
