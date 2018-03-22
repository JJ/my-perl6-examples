#!/usr/bin/env perl6

my Channel $c .= new;
$c.send($_) for ^20;
$c.close;
my Channel $c2 .= new;
my $work = start {
    $c2.send: $_ for $c.List.rotor(2);
    $c2.close;
    CATCH {
	default {
	    $c2.fail($_)
	}
    }
};
.say for $c2.List;
await $work;