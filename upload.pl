#!/usr/bin/perl
use Elive::StandardV2;
use Elive::StandardV2::Presentation;

my $content = 'the quick brown fox';

Elive::StandardV2->connect('http://rrmeo_sdk:teste10@10.0.0.1:8888');

my $presentation = Elive::StandardV2::Presentation->insert(
    {
	filename => 'intro.wbd',
	creatorId =>  'bob',
	content => $content,
    },
    );
