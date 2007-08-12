#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use warnings;
use strict;

# if (scalar @ARGV != 4) {
#   print 'usage: in-file out-file original-path new-path'
# }

my $string = "0123\0\0/Users/pipping/Gentoo/foo:/Users/pipping/Gentoo/bar\0\0/Users/pipping/Gentoo/bin:/Users/pipping/Gentoo/sbin:/Users/pipping/Gentoo/etc\0456";
my $search = "/Users/pipping/Gentoo";
my $replace = "/FOO";

if ( length( $search ) < length( $replace ) ) {
  die "the new prefix is longer than the old prefix"
}

$_ = $string;

my $olen = length();

#print "OLD string: " . $_ . "\n";
#print "OLD length: " . length() . "\n";

while ( /\G.*?$search/g ) {
  my $beg = pos() - length( $search );
  my $occurrences = 1;
  my @joints;
  while ( /\G([^\0]*?)$search/ ) {
    $occurrences++;
    push @joints, $1;
    pos() += length( $1 ) + length( $search );
  }
  /\G((?:.(?!$search))*?)(?=\0|$)/g;
  push @joints, $1;
  my $localrep = '';
  for ( my $i = 0; $i < $occurrences; $i++ ) {
    $localrep .= $replace . $joints[$i];
  }
  $localrep .= "\0" x (
    ( length( $search ) - length( $replace ) ) * $occurrences
  );
  my $len = pos() - $beg;
  print 'replacing `' . substr( $_, $beg, $len ) . "`\n";
  print 'with      `' . $localrep . ".\n";
  substr( $_, $beg, $len ) = $localrep;
}

#print "NEW string: " . $_ . "\n";
#print "NEW length: " . length() . "\n";

my $nlen = length();

die "the file size changed, this should now happen" if $nlen != $olen;
