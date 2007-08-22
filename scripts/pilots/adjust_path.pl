#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use warnings;
use strict;

die 'usage: in-file out-file original-path new-path' if scalar @ARGV != 4;

my ( $ifile, $ofile, $search, $replace ) = @ARGV;

if ( length( $search ) < length( $replace ) ) {
	die "The new prefix is longer than the old one."
}

# prepare regex library
my $imatch = qr/\G.*?$search/so;				# initial match
my $cmatch = qr/\G(.*?)$search/so;				# continued match
my $tmatch = qr/\G(.*?)(?!$search)(?=\0?$)/so;	# tail of match

$/ = "\0";
open( IFILE, "<$ifile" ) or die "Could not open $ifile for reading: $!";
open( OFILE, ">$ofile" ) or die "Could not open $ofile for writing: $!";

while (<IFILE>) {
	while ( m/$imatch/g ) {
		my $beg = pos() - length( $search );
		my $occurrences = 1;
		my @joints;
		while ( m/$cmatch/ ) {
			$occurrences++;
			push @joints, $1;
			pos() += length( $1 ) + length( $search )
		}
		m/$tmatch/g;
		push @joints, $1;
		my $localrep;
		for ( my $i = 0; $i < $occurrences; $i++ ) {
			$localrep .= $replace . $joints[$i]
		}
		$localrep .= "\0" x (
			( length( $search ) - length( $replace ) ) * $occurrences
		);
		my $len = pos() - $beg;
		print '< ' . substr( $_, $beg, $len ) . "\n";
		print '> ' . $localrep . "\n";
		my $buf = pos();
		substr( $_, $beg, $len ) = $localrep;
		pos() = $buf
	}
	print OFILE
}

close( IFILE );
close( OFILE );

# vim: set ts=4 sw=4 noexpandtab:
