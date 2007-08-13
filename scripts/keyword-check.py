#! /usr/bin/env python
# Copyright Gentoo Foundation 2007

import glob
import fileinput
import re

archlist = []
first = 1

for arch in open( 'profiles/arch.list', 'r' ).readlines():
	arch = arch.rstrip()
	if arch != '' and arch != 'prefix' and not arch.startswith( '#' ):
		archlist.append( arch )

for file in glob.glob( '*/*/*.ebuild' ):
	for line in fileinput.input( [file] ):
		if line.startswith( 'KEYWORDS=' ):
			forbidden=[]
			stable=[]
			for kw in re.split( '\s+', line.split( '"' )[1] ):
				if kw == '': pass
				else:
					if not kw.startswith( '~' ) and not kw.startswith( '-' ):
						stable.append( kw )
					else:
						kw=kw.lstrip( '~-' )
					if not kw in archlist: forbidden.append( kw )
			if len( stable ) != 0 or len( forbidden ) != 0:
				if not first: print
				else: first=0
				print 'EBUILD    : %s' % re.sub( '/[^/]+/', '/', file )
				if len( forbidden ) != 0:
					print 'forbidden : %s' % ' '.join( forbidden )
				if len( stable ) != 0:
					print 'stable    : %s' % ' '.join( stable )

# vim: set ts=4 sw=4 noexpandtab:
