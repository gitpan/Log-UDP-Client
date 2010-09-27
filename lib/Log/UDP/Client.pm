use strict;
use warnings;
use 5.006; # Found with Perl::MinimumVersion

package Log::UDP::Client;
BEGIN {
  $Log::UDP::Client::VERSION = '0.20.0';
}
use Moose;
with 'Data::Serializable' => { -version => '0.40.0' };

# ABSTRACT: A simple way to send structured log messages via UDP

use IO::Socket::INET ();
use Carp qw(carp croak);


has "server_address" => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { "127.0.0.1"; },
);


has "server_port" => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { 9999; }
);


has "throws_exception" => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);


has "socket" => (
    is      => 'ro',
    isa     => 'IO::Socket::INET',
    lazy    => 1,
    default => sub { IO::Socket::INET->new( Proto => 'udp' ); }
);


# Perl::Critic bug: Subroutines::RequireArgUnpacking shouldn't be needed here
## no critic qw(Subroutines::ProhibitBuiltinHomonyms Subroutines::RequireArgUnpacking)
sub send {
    my ($self, $message) = @_;

    # Make sure message was specified
    if ( @_ < 2 ) {
        croak("Please specify message") if $self->throws_exception;
        return; # FAIL
    }

    # Use the specified serializer to encode the message in a binary format
    my $serialized_message = $self->serialize( $message );

    # Trap failure in serialization when not emitting exceptions
    if ( not $self->throws_exception and not defined($serialized_message) ) {
        return; # FAIL
    }

    # Send UDP message
    my $length = CORE::send(
        $self->socket,
        $serialized_message,
        0,
        IO::Socket::INET::pack_sockaddr_in(
            $self->server_port,
            IO::Socket::INET::inet_aton( $self->server_address )
        )
    );

    # Check for transmission error
    if ( $length != length($serialized_message) ) {
        my $error = "Couldn't send message: $!\n";
        croak($error) if $self->throws_exception;
        carp($error);
        return 0;
    }

    # Everything OK
    return 1;

}

1;



=pod

=encoding utf-8

=head1 NAME

Log::UDP::Client - A simple way to send structured log messages via UDP

=head1 VERSION

version 0.20.0

=head1 SYNOPSIS

    use Log::UDP::Client;

    # Send the simple scalar to the server
    Log::UDP::Client->new->send("Hi");

    # Log lots of messages
    my $logger = Log::UDP::Client->new(server_port => 15000);
    my $counter=0;
    while(++$counter) {
        $logger->send($counter);
        last if $counter >= 1000;
    }

    # Send some debugging info
    $logger->send({
        pid     => $$,
        program => $0,
        args    => \@ARGV,
    });

    # Use of JSON serializer
    my $logger = Log::UDP::Client->new( serializer_module => 'JSON' );

    # Will emit { "message" => "Hi" } because JSON want to wrap stuff into a hashref
    $logger->send("Hi");

    # Use of custom serializer
    use Storable qw(freeze);
    my $logger = Log::UDP::Client->new (
        serializer => sub {
            return nfreeze( \( $_[0] ) );
        },
    );

=head1 DESCRIPTION

This module enables you to send a message (simple string or complicated object)
over an UDP socket to a listening server. The message will be encoded with a
serializer module (default is L<Storable>).

=head1 ATTRIBUTES

=head2 server_address : Str

IP address or hostname for the server you want to send the messages to.
This field can be changed after instantiation. Default is 127.0.0.1.

=head2 server_port : Int

Port for the server you plan to send the messages to.
This field can be changed after instantiation. Default is port 9999.

=head2 throws_exception : Bool

If errors are encountered, should we throw exception or just return?
Default is return. Set to true for exceptions. You can change this flag
after instantiation.

=head2 socket : IO::Socket::INET

Read-only field that contains the socket used to send the messages.

=head1 METHODS

=head2 send($message)

Instance method that actually encodes and transmits the specified message
over UDP to the listening server. Will die if throw_exception is set to true
and some kind of transmission error occurs. The message will be serialized by
the instance-defined serializer. Returns true on success.

=head1 INHERITED METHODS

=over 4

=item *

deserialize

=item *

deserializer

=item *

serialize

=item *

serializer

=item *

serializer_module

=back

All of these methods are inherited from L<Data::Serializable>. Read more about them there.

=head1 SEE ALSO

=over 4

=item *

L<Moose>

=item *

L<Storable>

=item *

L<JSON::XS>

=item *

L<IO::Socket::INET>

=back

=for :stopwords CPAN AnnoCPAN RT CPANTS Kwalitee diff

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc Log::UDP::Client

=head2 Websites

=over 4

=item *

Search CPAN

L<http://search.cpan.org/dist/Log-UDP-Client>

=item *

AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-UDP-Client>

=item *

CPAN Ratings

L<http://cpanratings.perl.org/d/Log-UDP-Client>

=item *

CPAN Forum

L<http://cpanforum.com/dist/Log-UDP-Client>

=item *

RT: CPAN's Bug Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-UDP-Client>

=item *

CPANTS Kwalitee

L<http://cpants.perl.org/dist/overview/Log-UDP-Client>

=item *

CPAN Testers Results

L<http://cpantesters.org/distro/L/Log-UDP-Client.html>

=item *

CPAN Testers Matrix

L<http://matrix.cpantesters.org/?dist=Log-UDP-Client>

=item *

Source Code Repository

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<git://github.com/robinsmidsrod/Log-UDP-Client.git>

=back

=head2 Bugs

Please report any bugs or feature requests to C<bug-log-udp-client at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-UDP-Client>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 AUTHOR

Robin Smidsrød <robin@smidsrod.no>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Robin Smidsrød.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

