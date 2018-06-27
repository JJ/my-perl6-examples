#!/usr/bin/env perl6

use v6;

#Original program by bdfoy, https://stackoverflow.com/questions/42505139/does-changing-perl-6s-out-change-standard-output-for-child-processes

my $program = Q:to/END/;
    #!/usr/bin/env perl6

    $*OUT.say( qq/\t$*PROGRAM: This goes to standard output/ );
END
   
spurt "/tmp/program.p6", $program;

$*OUT.put: "1. standard output before doing anything weird";

{
    temp $*OUT = open '/tmp/out.txt', :w;
    $*OUT.put: "2. temp redefine standard output before this message";
    shell( "perl6 /tmp/program.p6" ).so;
}

$*OUT.put: "4. everything should be back to normal";
