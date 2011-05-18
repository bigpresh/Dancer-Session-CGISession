#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Dancer::Session::CGISession' ) || print "Bail out!
";
}

diag( "Testing Dancer::Session::CGISession $Dancer::Session::CGISession::VERSION, Perl $], $^X" );
