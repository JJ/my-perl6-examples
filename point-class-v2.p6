#!/usr/bin/env perl6

use v6;

class Str-with-ID is Str {
    my $counter = 0;
    has Int $.ID  is rw = 0;

    multi method new( $str ) {
        self.bless( value => $str );
    }

    submethod BUILD( :$!ID = $counter++   ) { }
}

say Str-with-ID.new("1.1-2e2").ID;
my $ided-str = Str-with-ID.new("3-4");
say "$ided-str, {$ided-str.^name}, {$ided-str.ID}";




