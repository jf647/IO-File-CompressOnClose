#
# $Header$
#

=head1 NAME

IO::File::CompressOnCloset::Gzip - Gzip compression for IO::File::AutoCompress

=head1 SYNOPSIS

 use IO::File::AutoCompress::Gzip;
 my $file = IO::File::AutoCompress::Gzip->new('>foo');
 print $file "foo bar baz\n";
 $file->close;  # file will be compressed to foo.gz
 
=cut
 
package IO::File::AutoCompress::Gzip;
use base 'IO::File::AutoCompress';

use strict;
use warnings;

our $VERSION = 0.010_000;

use IO::File;
use IO::Zlib;

# compress using gzip
sub compress
{

    my $self = shift;
    
    # get the filename from our glob
    my $filename = ${*$self}->{filename};
    
    # tack on a .gz extension
    my $destfilename = "$filename.gz";
    
    # recompress the file
    my($in,$out);
    unless( $in = IO::File->new($filename, 'r') ) {
        require Carp;
        Carp::croak("cannot open $filename for read: $!");
    }
    unless( $out = IO::Zlib->new($destfilename, 'w') ) {
        require Carp;
        Carp::croak("cannot open $destfilename for write: $!");
    }

    while( <$in> ) {
        print $out $_;
    }

    # close both files
    unless( $in->close ) {
        require Carp;
        Carp::croak("cannot close $filename after read: $!");
    }
    unless( $out->close ) {
        require Carp;
        Carp::croak("cannot close $destfilename after write: $!");
    }
    
    # unlink the original file
    unless( unlink($filename) ) {
        require Carp;
        Carp::croak("cannot unlink $filename after compress: $!");
    }
    

}

#
# EOF
