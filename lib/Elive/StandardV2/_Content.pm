package Elive::StandardV2::_Content;
use warnings; use strict;

use Mouse;

use Carp;
use Try::Tiny;

extends 'Elive::StandardV2';

=head1 NAME

Elive::StandardV2::_Content - Base class for Presentation and Mulitmedia content

=cut

sub BUILDARGS {
    my $class = shift;
    my $spec = shift;

    my %args;

    if ($spec && ! ref($spec) ) {
	#
	# Assume a single string arguments represents the local path of a file
	# to be uploaded.
	#
	my $preload_path = $spec;

	open ( my $fh, '<', $preload_path)
	    or die "unable to open preload file $preload_path";

	binmode $fh;
	my $content = do {local $/; <$fh>};

	close $fh;

	die "upload file is empty: $preload_path"
	    unless length $content;

	my $filename = File::Basename::basename( $preload_path );
	croak "unable to determine a basename for preload path: $preload_path"
	    unless length $preload_path;

	%args = (
	    filename => $preload_path,
	    content => $content,
	);
    }
    elsif (Elive::Util::_reftype($spec) eq 'HASH') {
	%args = %$spec;
    }
    else {
	croak 'usage: '.$class.'->new( filepath | {name => $filename, content => $binary_data, ...} )';
    }

    if ($args{content}) {
	$args{size} ||= length( $args{content} );
    }

    return \%args;
}

sub _freeze {
    my $class = shift;
    my $db_data = shift;

    $db_data = $class->SUPER::_freeze( $db_data );

    for (grep {$_} $db_data->{content}) {
	$db_data->{size} ||= Elive::Util::_freeze( length($_), 'Int');

	#
	# (a bit of layer bleed here...). Do we need a separate data type
	# for base 64 encoded data?
	#
	try {require SOAP::Lite} catch {die $_};
	$_ = SOAP::Data->type(base64 => $_);
    }

    return $db_data;
}

sub upload {
    my ($class, $spec, %opt) = @_;

    my $upload_data = $class->BUILDARGS( $spec );
    $upload_data->{creatorId} ||= do {
	my $connection = $opt{connection} || $class->connection
	    or die "not connected";

	$connection->user;
    };

    my $self = $class->SUPER::insert($upload_data, %opt);

    return $self;
}

1;
