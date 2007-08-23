#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use strict;
use warnings;

# create a hash of valid architectures
my $filename = 'profiles/arch.list';

open ARCHLIST, "< $filename" or die "Cannot open $filename : $!";

my %arch;
while ( <ARCHLIST> ) {
	chomp;
	$arch{$_} = 1 unless m/^(?:#|(?:prefix)?$)/;
}

close ARCHLIST;

# we have yet to print to the screen
my $first = 1;

# process ebuilds
while ( defined( my $ebuild = <*-*/*/*.ebuild> ) ) { 
	@ARGV = $ebuild;
	while ( <> ) {
		if ( ?^KEYWORDS=? ) {
			my ( @forbidden, @stable );

			# check keywords for validity
			foreach ( split /\s+/, ( split q{"} )[1] ) {
				push @stable, $_ unless ( s/^[-~]// );
				push @forbidden, $_ unless ( $arch{$_} );
			}

			# print a report if necessary
			if ( @forbidden || @stable ) {
				unless ( $first ) { print "\n" } else { $first=0 }
				$ebuild =~ s{/[^/]+/}{/};
				$ebuild = substr( $ebuild, 0, length( $ebuild ) - 7 );
				printf "EBUILD    : %s\n", $ebuild;
				printf "forbidden : %s\n", @forbidden if ( @forbidden );
				printf "stable    : %s\n", @stable if ( @stable );
			}
		}
	} continue {
		reset if eof;
	}
}

# vim: set ts=4 sw=4 noexpandtab:
