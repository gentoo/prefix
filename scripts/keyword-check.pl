#! /usr/bin/env perl
# Copyright Gentoo Foundation 2007

use strict;
use warnings;

# process archlist
my $filename = 'profiles/arch.list';

open( ARCHLIST, "< $filename" ) or die "Cannot open $filename : $!";

my @archlist;
while( <ARCHLIST> ) {
	chomp;
	push @archlist, $_ unless m/^(?:#|(?:prefix)?$)/
}

close( ARCHLIST );

# we have yet to print to the screen
my $first = 1;

# process ebuilds
while (defined(my $ebuild = <*-*/*/*.ebuild>)) { 
	@ARGV = $ebuild;
	while (<>) {
		if ( ?^KEYWORDS=? ) {
			my @forbidden; my @stable;
			# iterate over the keywords
			foreach ( split( /\s+/, ( split( '"' ) )[1] ) ) {
				push( @stable, $_ ) unless ( s/^[-~]// );
				my $allowed = 0;
				foreach my $arch (@archlist) {
					if ( $arch eq $_ ) {
						$allowed = 1;
						last
					}
				}
				push( @forbidden, $_ ) unless ( $allowed )
			}
			# give a report
			if ( scalar @forbidden or scalar @stable ) {
				unless ( $first ) { print "\n" } else { $first=0 }
				$ebuild =~ s{/[^/]+/}{/};
				$ebuild = substr( $ebuild, 0, length( $ebuild ) - 7 );
				printf "EBUILD    : %s\n", $ebuild;
				printf "forbidden : %s\n", @forbidden if ( scalar @forbidden );
				printf "stable    : %s\n", @stable if ( scalar @stable )
			}
		}
	} continue {
		reset if eof
	}
}

# vim: set ts=4 sw=4 noexpandtab:
