#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use warnings;
use strict;

die 'usage: in-file out-file original-path new-path' if scalar @ARGV != 4;

( my $infile, my $outfile, my $search, my $replace ) = @ARGV;

if ( length( $search ) < length( $replace ) ) {
	die "The new prefix is longer than the old one."
}

undef $/;
open( INFILE, "<$infile" ) or die "Could not open $infile for reading: $!";
$_ = <INFILE>;

my $olen = length();

# prepare regex library
my $fmatch = qr/\G(?:.|\n)*?$search/o;
my $cmatch = qr/\G([^\0]*?)$search/o;
my $tmatch = qr/\G((?:.(?!$search))*?)(?=\0|$)/o;

while ( m/$fmatch/g ) {
	my $beg = pos() - length( $search );
	my $occurrences = 1;
	my @joints;
	while ( m/$cmatch/ ) {
		$occurrences++;
		push @joints, $1;
		pos() += length( $1 ) + length( $search );
	}
	m/$tmatch/g;
	push @joints, $1;
	my $localrep = '';
	for ( my $i = 0; $i < $occurrences; $i++ ) {
		$localrep .= $replace . $joints[$i];
	}
	$localrep .= "\0" x (
		( length( $search ) - length( $replace ) ) * $occurrences
	);
	my $len = pos() - $beg;
	#print 'replacing `' . substr( $_, $beg, $len ) . "`\n";
	#print 'with      `' . $localrep . ".\n";
	my $buffer = pos();
	substr( $_, $beg, $len ) = $localrep;
	pos() = $buffer;
}

my $nlen = length();

if ($nlen != $olen) {
	die 'The file size has changed, this should not happen. Nothing was written'
}

open( OUTFILE, ">$outfile" ) or die "Could not open $outfile for writing: $!";
print OUTFILE ( $_ );
close( OUTFILE )

# vim: set ts=4 sw=4 noexpandtab:
