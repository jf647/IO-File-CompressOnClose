use blib;
use Test::More;
use_ok('IO::File::AutoCompress');
is($IO::File::AutoCompress::VERSION', 1.000_000,
    'module version is 1.000_000');
