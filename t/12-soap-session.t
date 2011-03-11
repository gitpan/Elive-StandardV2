#!perl
use warnings; use strict;
use Test::More tests => 21;
use Test::Exception;
use Test::Builder;
use version;

use lib '.';
use t::Elive::StandardV2;

use Elive::StandardV2::Session;
use Elive::Util;

our $t = Test::Builder->new;
our $class = 'Elive::StandardV2::Session';

our $connection;

SKIP: {

    my $skippable = 21;

    my %result = t::Elive::StandardV2->test_connection();
    my $auth = $result{auth};

   skip ($result{reason} || 'skipping live tests', $skippable)
	unless $auth && @$auth;

    eval{require Elive::StandardV2::Connection};
    die $@ if $@;
    my $connection_class = $result{class};
    $connection = $connection_class->connect(@$auth);
    Elive::StandardV2->connection($connection);

    my $session_start = Elive::Util::next_quarter_hour();
    my $session_end = Elive::Util::next_quarter_hour( $session_start );

    $session_start .= '000';
    $session_end .= '000';

    my %insert_data = (
	sessionName => 'test session, generated by t/12-soap-session.t',
	creatorId => $connection->user,
	startTime =>  $session_start,
	endTime => $session_end,
	openChair => 1,
	mustBeSupervised => 0,
	permissionsOn => 1,
	groupingList => [qw(mechanics sewing)],
    );

    my ($session) = $class->insert(\%insert_data);

    isa_ok($session, $class, 'session');
    ok(my $session_id = $session->sessionId, 'Insert returned session id');

    diag "session-id: $session_id";

    foreach (keys %insert_data) {
	#
	# returned record doesn't contain password
	is_deeply($session->$_, $insert_data{$_}, "session $_ as expected");
    }

    my %update_data = (
	chairNotes => 'test moderator notes. Here are some entities: & > <',
	nonChairNotes => 'test user notes; some more entities: &gt;',
	raiseHandOnEnter => 1,
	maxTalkers => 3,
	recordingModeType => 2,
	);

    $session->update(\%update_data);

    $session = undef;

    ok ($session = Elive::StandardV2::Session->retrieve([$session_id]),
	'Refetch of session');

    foreach (keys %update_data) {
	#
	# returned record doesn't contain password
	is($session->$_, $update_data{$_}, "session update $_ as expected");
    }

    my $session_url;
    lives_ok(sub {$session_url = $session->session_url(user_id => 'bob', display_name => 'Robert')}, 'Can generate session Url for some user');
    diag "session url: $session_url";

    my $attendances;

    dies_ok(sub {$attendances = $session->attendance('')}, 'session attendance sans date - dies');

    my $today_hires = $session_start - 7200;
    lives_ok(sub {$attendances = $session->attendance($today_hires)}, 'session attendance with date - lives');

    lives_ok(sub {$session->delete},'session deletion - lives');

    my $deleted_session;
    eval {$deleted_session = Elive::StandardV2::Session->retrieve([$session_id])};

    ok($@ || !$deleted_session, "can't retrieve deleted session");
}

Elive::StandardV2->disconnect;

