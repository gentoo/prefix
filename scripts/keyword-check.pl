#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use strict;
use warnings;
use Carp;

# create a hash of valid architectures
my $filename = 'profiles/arch.list';

open my $archlist_handle, '<', $filename or croak "Cannot open $filename : $!";

my %arch;
while ( <$archlist_handle> ) {
	chomp;
	$arch{$_} = ! m/^(?:\#|(?:prefix)?$)/xms;
}

close $archlist_handle or croak "couldn't close $archlist_handle";

# we have yet to print to the screen
my $first = 1;

# process ebuilds
while ( defined( my $ebuild = glob '*-*/*/*.ebuild' ) ) {
	@ARGV = $ebuild;
	while ( <> ) {
		if ( ?^KEYWORDS=?x ) {
			my ( @forbidden, @stable );

			# check keywords for validity
			foreach ( split /\s+/xms, ( split qr{"} )[1] ) {
				if ( ! s/^[-~]//xms ) {
					push @stable, $_;
				}
				if ( ! $arch{$_} ) {
					push @forbidden, $_;
				}
			}

			# print a report if necessary
			if ( @forbidden || @stable ) {
				if ( ! $first ) {
					print "\n";
				}
				else {
					$first=0;
				}
				$ebuild =~ s,/[^/]+/,/,xms;
				$ebuild = substr $ebuild, 0, length( $ebuild ) - 7;
				printf "EBUILD    : %s\n", $ebuild;
 				if ( @forbidden ) {
					printf "forbidden : %s\n", @forbidden;
				}
				if ( @stable ) {
					printf "stable    : %s\n", @stable;
				}
			}
		}
	} continue {
		if (eof) {
			reset;
		}
	}
}

# vim: set ts=4 sw=4 noexpandtab:
