use Test::More 'no_plan';

use IO::File::AutoCompress;

eval {
    my $file = IO::File::AutoCompress->new('foo', 'w');
    print $file "foo bar baz\n";
    $file->close;
};

ok( ! $@, 'open/print/close a file');
