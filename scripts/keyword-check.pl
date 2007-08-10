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
			my $str = substr( $_, 9 );
			# get rid of the quotes and the newline
			$str = substr( $str, 1, length ($str)-3 );
			my @kws = split( /\s+/, $str );
			my @forbidden;
			my @stable;
			foreach (@kws) {
				my $unstable = s/^[-~]//;
				unless ( $unstable ) {
					push @stable, $_
				}
				my $allowed = 0;
				foreach my $arch (@archlist) {
					my $included = $arch eq $_;
					if ($included) {
						$allowed = 1;
						last
					}
				}
				unless ($allowed) {
					push @forbidden, $_
				}
			}
			# give a report
			if ( scalar @forbidden or scalar @stable ) {
				unless ($first) { print "\n" } else { $first=0 }
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
