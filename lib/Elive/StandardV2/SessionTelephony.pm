package Elive::StandardV2::SessionTelephony;
use warnings; use strict;

use Mouse;

extends 'Elive::StandardV2';

use Scalar::Util;
use Carp;

use Elive::Util;

=head1 NAME

Elive::StandardV2::SessionTelephony - Elluminate Session Telephony instance class

=head1 DESCRIPTION

This class is used to setup telephony information for an existing session

=cut

__PACKAGE__->entity_name('SessionTelephony');

=head1 PROPERTIES

=head2 sessionId (Int)

The identifier of the session.

=cut

has 'sessionId' => (is => 'rw', isa => 'Int', required => 1);
__PACKAGE__->_isa('Session');
__PACKAGE__->primary_key('sessionId');

=head2 chairPhone (Str)

The phone number for the session chair (also known as a session moderator) when the Elluminate Live! session is running.

=cut

has 'chairPhone' => (is => 'rw', isa => 'Str',
		     documentation => 'The phone number for the session chair'
    );

=head2 chairPIN (Str)

The PIN for the chairPhone.

=cut

has 'chairPIN' => (is => 'rw', isa => 'Str',
		   documentation => 'The PIN for the chairPhone'
    );

=head2 nonChairPhone (Str)

The phone number used by the session non-chair users (also known as a session participants). The information is for display purposes only in the Elluminate Live! session (so participants know what telephone number and PIN to use to connect to the teleconference).

=cut

has 'nonChairPhone' => (is => 'rw', isa => 'Str',
		     documentation => 'The phone number for the non-chair participants'
    );

=head2 nonChairPIN (Str)

The PIN for the nonChairPhone.

=cut

has 'nonChairPIN' => (is => 'rw', isa => 'Str',
		      documentation => 'The PIN for the nonChairPhone participants'
    );

=head2 isPhone (Bool)

Used to indicate if the C<sessionSIPPhone> field should be validated as a Session Initiation Protocol (SIP) or phone number.

=cut

has 'isPhone' => (is => 'rw', isa => 'Bool',
		  documentation => 'true if a simple phone, false if also using Session Initiation Protocol (SIP)?',
    );


=head2 sessionSIPPhone (Str)

The Session Initiation Protocol (SIP) or phone number used by the Elluminate Live! session. Sometimes referred to as the session bridge or teleconference bridge.
For accepted phone number and SIP formats, see Notes About Session Telephony Validation on page 67.

=cut

has 'sessionSIPPhone' => (is => 'rw', isa => 'Str',
		     documentation => 'The phone number used by SIP participants'
    );

=head2 sessionPIN (Str)

The PIN for the C<sessionSIPPhone>.

=cut

has 'sessionPIN' => (is => 'rw', isa => 'Str',
		      documentation => 'The PIN number for SIP participants',
    );


=head1 METHODS

=cut

=head2 update

    my $session_telephony = $session->telephony;

    my %telephony_data = (
	chairPhone => '(03) 5999 1234',
	chairPIN   => '6342',
	nonChairPhone => '(03) 5999 2234',
	nonChairPIN   => '7722',
	isPhone => '1',
	sessionSIPPhone => '(03) 6999 2222',
	sessionPIN => '1234',
	);

    $session_telephony->update(\%telephony_data);

Updates a session's telephony characteristics.

=cut

=head1 SEE ALSO

I<Elluminate_Live_Standard_Bridge_API_ELM_v2.0.pdf> - please see
the C<setSessionTelephony> command.

=cut

1;
