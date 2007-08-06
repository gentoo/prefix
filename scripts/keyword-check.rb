#!/usr/bin/env ruby -w
# Copyright Gentoo Foundation 2007

require 'pathname'
require 'set'

lines = Pathname.new( 'profiles/arch.list' ).readlines
allowed = lines.collect {|line| line.chomp }.reject {|line|
	line.slice( 0, 1 ) == '#' or line.empty? or line == 'prefix'
}

kmods = Set.new [ '~', '-' ]

Pathname.new( '.' ).find {|file| 
	next unless file.fnmatch? '*.ebuild'
	file.readlines.each {|line|
		unless line.slice( 0, 9 ) == 'KEYWORDS='
			next
		else
			kws = line.chomp.slice( 10..-2 )
			next if kws.empty?
			forbidden = Array.new
			stable    = Array.new
			kws.split.each {|kw|
				# keywords are only allowed to start with a tilde for now
				# but keywords are only stable if there is no - in front of them
				stable << kw if is_stable = !kmods.include?( kw.slice( 0, 1 ) )
				forbidden << kw unless allowed.include?(
					is_stable ? kw : kw.slice( 1..-1 )
				)
			}
			if stable.any? or forbidden.any?
				puts 'EBUILD    : %s' % [ file.dirname.dirname + file.basename ]
				puts 'stable    : %s' % stable.join( " "  ) if stable.any?
				puts 'forbidden : %s' % forbidden.join( " " ) if forbidden.any?
				puts
			end
		end
	}
}

# vim: set ts=2 sw=2 noexpandtab:
