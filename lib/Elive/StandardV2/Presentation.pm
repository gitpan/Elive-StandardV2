package Elive::StandardV2::Presentation;
use warnings; use strict;

use Mouse;

extends 'Elive::StandardV2';

use Scalar::Util;
use Carp;

=head1 NAME

Elive::StandardV2::Presentation - Presentation entity class

=cut

__PACKAGE__->entity_name('Presentation');

has 'presentationId' => (is => 'rw', isa => 'Int', required => 1);
__PACKAGE__->primary_key('presentationId');
__PACKAGE__->params(
    content => 'Str',
    sessionId => 'Int',
    );

has 'description' => (is => 'rw', isa => 'Str');
has 'size' => (is => 'rw', isa => 'Int');
has 'creatorId' => (is => 'rw', isa => 'Str');
has 'filename' => (is => 'rw', isa => 'Str');

=head1 METHODS

=cut

=head2 insert

Uploads content and creates a new presentation resource.

    # get the binary data from somewhere
    open (my $rec_fh, '<', $presentation_path)
        or die "unable to open $presentation_path: $!";

    my $content = do {local $/ = undef; <$rec_fh>};
    die "no presentation data: $presentation_path"
        unless ($content);

    my $presentation = Elive::StandardV2::Presentation->insert(
             {
                    filename => 'intro.wav',
                    creatorId =>  'bob',
                    content => $content,
	     },
         );

=cut

sub _freeze {
    my $class = shift;
    my $db_data = shift;

    $db_data = $class->SUPER::_freeze( $db_data );

    for (grep {$_} $db_data->{content}) {
##	$db_data->{size} ||= Elive::Util::_freeze( length($_), 'Int');

	#
	# (a bit of layer bleed here...). Do we need a seperate data type
	# for base 64 encoded data?
	#
	eval {require SOAP::Lite}; die $@ if $@;
	$_ = SOAP::Data->type(base64 => $_);
##	use MIME::Base64;
##	chomp($_ = MIME::Base64::encode_base64( $_ ));
	
    }

    return $db_data;
}

sub insert {
    my ($class, $insert_data, %opt) = @_;

    my $self = $class->SUPER::insert($insert_data,
				     command => 'uploadPresentationContent',
				     %opt);

    return $self;
}

=head2 list

    my $session_presentations = Elive::StandardV2::Presentation->list(
                                   filter => {sessionId => $my_session}
                                );

Lists sessions. You will need to provide a filter that contains at least one
of: C<creatorId>, C<presentationId>, C<description> or C<sessionId>.

=cut

sub list {
    my ($self, %opts) = @_;

    return $self->SUPER::list(
	command => sub {
	    my ($_crud, $params) = @_;

	    return $params->{sessionId} ? 'listSessionPresentation': 'listPresentationContent'
	},
	%opts);
}

1;