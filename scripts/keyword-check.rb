#!/usr/bin/env ruby -w
# Copyright 2008-2014 Gentoo Foundation; Distributed under the GPL v2

%w{ pathname set }.each {|lib| require lib}

lines = Pathname.new( 'profiles/arch.list' ).readlines
allowed = lines.collect {|line| line.chomp }.reject {|line|
	line.slice( 0, 1 ) == '#' or line.empty?
}

kmods = Set.new %w{ ~ - }

start = Time.now
problemCnt = 0

Pathname.new( '.' ).find {|file| 
	next unless file.fnmatch? '*/*/*.ebuild'
	file.readlines.each {|line|
		unless line.slice( 0, 9 ) == 'KEYWORDS='
			next
		else
			kws = line.chomp.slice( 10..-2 )
			break if kws.empty?
			forbidden = Array.new
			stable    = Array.new
			kws.split.each {|kw|
				# keywords are only allowed to start with a tilde for now but
				# keywords are only stable if there is no - in front of them
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
				problemCnt += 1
			end
			break
		end
	}
}

if problemCnt > 0
	puts 'found %d packages with problems in %.1fs' %
		[ problemCnt, (Time.new - start) ]
end

# vim: set ts=4 sw=4 noexpandtab:
