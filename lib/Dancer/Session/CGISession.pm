package Dancer::Session::CGISession;

use warnings;
use strict;
use base 'Dancer::Session::Abstract';
use Carp;
use Dancer::Config 'setting';
use Dancer::FileUtils 'path';


=head1 NAME

Dancer::Session::CGISession - CGI::Session session engine for Dancer

=head1 DESCRIPTION

A session engine wrapper to allow Dancer apps to use CGI::Session sessions.
Mostly useful if you need to share sessions created by non-Dancer apps which are
already using CGI::Session.

Work in progress; not yet ready for use.

=cut

our $VERSION = '0.01';

our $cgisession;
our $session_driver;
our $session_driver_params;

# Default to a cookie named CGISESSID, for CGI::Session compatibility.
sub session_name {
        setting('session_name') || 'CGISESSID';
}


sub init {
        my ($self) = @_;

        croak "CGI::Session is needed and is not installed"
            unless Dancer::ModuleLoader->load('CGI::Session');

        my $session_driver = 'driver:'
            . ( setting('cgisession_driver') || 'File' );
        my $session_driver_params = setting('cgisession_driver_params') || {};

        # If it's the 'File' driver, make sure the session dir is used:
        if ($session_driver eq 'File') {
            # Default session storage dir
            my $session_dir = setting('session_dir')
                || path(setting('appdir'), 'sessions');

            # Make sure that dir exiats
            if (!-d $session_dir) {
                mkdir $session_dir
                    or croak "session_dir $session_dir cannot be created";
            }
            $session_driver_params->{Directory} ||= $session_dir;
        }
        $self->id(build_id());
}

sub retrieve {
    my ($class, $id) = @_;
    my $session = CGI::Session->load( 
        $session_driver, $id, $session_driver_params
    );
    my $self = $class->new;
    $self->{cgisession} = $session;
    return $self;
}

sub create {
    my $class = shift;
    my $session = CGI::Session->new(
        $session_driver, undef, $session_driver_params
    );
    my $self = $class->new;
    $self->{cgisession} = $session;
    return $self;
}
sub id {
    return shift->{cgisession}->id;
}


sub destroy {
    my $self = shift;
    $self->{cgisession}->delete;
    $self->{cgisession}->flush;
    delete $self->{cgisession};
}

sub flush {
    my $self = shift;
    $self->{cgisession}->flush;
}

=head1 AUTHOR

David Precious, C<< <davidp at preshweb.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-session-cgisession at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Session-CGISession>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Session::CGISession


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Session-CGISession>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Session-CGISession>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Session-CGISession>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Session-CGISession/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 David Precious.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Dancer::Session::CGISession
