#
# $Header$
#

=head1 NAME

IO::File::AutoCompress - auto-compress a file when done writing to it

=head1 SYNOPSIS

 use IO::File::AutoCompress;
 my $file = IO::File::AutoCompress->new('>foo');
 print $file "foo bar baz\n";
 $file->close;  # file will be compressed to foo.gz

To change compression scheme:

 IO::File::AutoCompress->compressor(\&coderef);

Or use one of the pre-built classes:

 use IO::File::AutoCompress::Bzip2;
 my $file = ...

=cut

package IO::File::AutoCompress;
use base qw|Class::Data::Inheritable IO::File|;

use strict;
use warnings;

our $VERSION = 0.010_000;

# declare class accessor for compression subroutine
__PACKAGE__->mk_classdata('compressor');

# default compression format is gzip but can be changed
__PACKAGE__->compressor(\&compress_default);


# open the file
sub open
{

    my $self = shift;
    my($file) = @_;

    # get the absolute path to the file
    if (! File::Spec->file_name_is_absolute($file)) {
        $file = File::Spec->catfile(File::Spec->curdir(),$file);
    }

    # stash away the filename in our glob
    ${*$self}->{filename} = $file;
    
    # and dispatch to our parent class to do the real open
    $self->SUPER::open(@_);
    
}


# close the file
sub close
{

    my $self = shift;

    # skip out if we've already been invoked
    return 1 if( ${*$self}->{compressed} );
    
    # call the IO::File close
    $self->SUPER::close(@_);
    
    # make sure we have a valid compression func
    my $compressor = __PACKAGE__->compressor;
    unless( ref $compressor eq 'CODE' ) {
        require Carp;
        Carp::croak("compressor is not a CODEREF");
    }

    # now recompress the file
    $compressor->($self);
    
    # note that we have been compressed
    ${*$self}->{compressed} = 1;

}


# make sure that our close is called on object destruction
sub DESTROY { $_[0]->close }


# dispatch to default compression method
sub compress_default
{

    # default to gzip compression
    require IO::File::AutoCompress::Gzip;
    IO::File::AutoCompress::Gzip::compress(@_);
    
}

# keep require happy
1;


__END__


=head1 DESCRIPTION

=head1 AUTHOR

=head1 BUGS

=head1 COPYRIGHT

Copyright (c) 2003, James FitzGibbon.  All Rights Reserved.

This module is free software. It may be used, redistributed and/or modified
under the terms of the Perl Artistic License (see
http://www.perl.com/perl/misc/Artistic.html)

=cut

#
# EOF
