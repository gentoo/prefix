# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Author:  Martin Schlemmer <azarah@gentoo.org>
# Contributor: Ned Ludd <solar@gentoo.org>
# Contributor: Natanael Copa  <nat@c2i.net>
# Contributor: Carter Smithhart <derheld42@derheld.net>
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/files/awk/scanforssp.awk,v 1.7 2004/07/15 00:59:02 agriffis Exp $


# Does not seem to be used in this script.
function printn(string)
{
	printf("%s", string)
}

function einfo(string)
{
	printf(" %s %s%s", "\033[32;01m*\033[0m", string, "\n")
}

# Does not seem to be used in this script.
function einfon(string)
{
	printf(" %s %s" , "\033[32;01m*\033[0m", string)
}

function ewarn(string)
{
	printf(" %s %s%s" , "\033[33;01m*\033[0m", string, "\n")
}

# Does not seem to be used in this script.
function ewarnn(string)
{
	printf("%s %s" , "\032[33;01m*\033[0m", string)
}

function eerror(string)
{
	printf(" %s %s%s" , "\033[31;01m*\033[0m", string, "\n")
}

								# These are private, else wierd things
								# might happen ...
function iself(scan_files,		scan_file_pipe, scan_data) {
	# Can we open() a file and read() 4 bytes?
	scan_file_pipe = ("head -c 4 " scan_files " 2>/dev/null | tail -c 3")
	scan_file_pipe | getline scan_data
	close(scan_file_pipe)
	return ((scan_data == "ELF") ? 0 : 1)
}

BEGIN {
	# Do we have etcat ?
	pipe = ("which etcat 2>/dev/null")
	if ((((pipe) | getline etcat_data) > 0) && (etcat_data != ""))
		auto_etcat = 1
	else
		auto_etcat = 0

	# Fix bug that causes script to fail when pipe is not closed. Closes bug #36792
	close(pipe)

	DIRCOUNT = 0
	# Add the two default library paths
	DIRLIST[1] = "/lib"
	DIRLIST[2] = "/usr/lib"

	# Walk /etc/ld.so.conf line for line and get any library paths
	pipe = ("cat /etc/ld.so.conf 2>/dev/null | sort")
	while(((pipe) | getline ldsoconf_data) > 0) {

		if (ldsoconf_data !~ /^[[:space:]]*#/) {

			if (ldsoconf_data == "") continue

			# Remove any trailing comments
			sub(/#.*$/, "", ldsoconf_data)
			# Remove any trailing spaces
			sub(/[[:space:]]+$/, "", ldsoconf_data)
	
			split(ldsoconf_data, nodes, /[:,[:space:]]/)

			# Now add the rest from ld.so.conf
			for (x in nodes) {

				sub(/=.*/, "", nodes[x])
				sub(/\/$/, "", nodes[x])

				if (nodes[x] == "") continue

				CHILD = 0

				# Drop the directory if its a child directory of
				# one that was already added ...
				for (y in DIRLIST) {

					if (nodes[x] ~ "^" DIRLIST[y]) {
					
						CHILD = 1
						break
					}
				}

				if (CHILD) continue
		
				DIRLIST[++DIRCOUNT + 2] = nodes[x]
			}
		}
	}

# We have no guarantee that ld.so.conf have more library paths than
# the default, and its better scan files only in /lib and /usr/lib
# than nothing at all ...
#
#	exit_val = close(pipe)
#	if (exit_val != 0)
#	print(exit_val " - " ERRNO)
#
#	if (DIRCOUNT == 0) {
#		eerror("Could not read from /etc/ld.so.conf!")
#		exit 1
#	}

	# Correct DIRCOUNT, as we already added /lib and /usr/lib
	DIRCOUNT += 2

	# Add all the dirs in $PATH
	split(ENVIRON["PATH"], TMPPATHLIST, ":")
	count = asort(TMPPATHLIST, PATHLIST)
	for (x = 1;x <= count;x++) {

		ADDED = 0

		# Already added?
		for (dnode in DIRLIST)
			if (PATHLIST[x] == DIRLIST[dnode])
				ADDED = 1

		if (ADDED)
			continue

		# Valid?  If so, add it ...
		if (((PATHLIST[x] != "") && (PATHLIST[x] != "/") && (PATHLIST[x] != ".")))
			DIRLIST[++DIRCOUNT] = PATHLIST[x]
		
	}
	
	GCCLIBPREFIX = "/usr/lib/gcc-lib/"
	
	for (x = 1;x <= DIRCOUNT;x++) {

		# Do nothing if the target dir is gcc's internal library path
		if (DIRLIST[x] ~ GCCLIBPREFIX) continue

		einfo(" Scanning " ((x <= 9) ? "0"x : x)" of " DIRCOUNT " " DIRLIST[x] "...")
		
		pipe = ("find " DIRLIST[x] "/ -type f -perm -1 2>/dev/null")
		while ( (pipe | getline scan_files) > 0) {

                    #print scan_files
			# Do nothing if the file is located in gcc's internal lib path ...
			if (scan_files ~ GCCLIBPREFIX) continue
			# Or if its hardend files ...
			if (scan_files ~ "/lib/libgcc-3" ) continue
			# Or not a elf image ...
			if (iself(scan_files)) continue

                        scan_file_pipe = ("readelf -s " scan_files " 2>&1")
			while (((scan_file_pipe) | getline scan_data) > 0) {
                            bad = 0;
				if (scan_data ~ /__guard@GCC/ || scan_data ~ /__guard@@GCC/) {
                                bad = 1;
					print

					# 194: 00000000    32 OBJECT  GLOBAL DEFAULT  UND __guard@GCC_3.0 (3)
					# 59: 00008ee0    32 OBJECT  GLOBAL DEFAULT   22 __guard@@GCC_3.0
					split(scan_data, scan_data_nodes)
					ewarn("Found " scan_data_nodes[8] " in " scan_files "!")
					print
                            }
                            if (scan_data ~ /readelf: Error: Unable to seek/) {
                                bad = 1;
                                print
                                ewarn("Error executing readelf. Bad block? Filesystem error? in " scan_files)
                                print
                            }

                            if (bad) {

					if (auto_etcat) {
					
						# Use etcat that comes with gentoolkit if auto_etcat is true.
						etcat_pipe = ("etcat belongs " scan_files)
						(etcat_pipe) | getline etcat_belongs

						while(((etcat_pipe) | getline etcat_belongs) > 0)
							eerror(etcat_belongs != "" ? "Please emerge '>=" etcat_belongs "'": "")
						close(etcat_pipe)
					} else {
					
						eerror("You need to remerge package that above file belongs to!")
						eerror("To find out what package it is, please emerge gentoolkit,")
						eerror("and then run:")
						print
						print "    # etcat belongs " scan_files
					}

					print
					
					close(scan_file_pipe)
					close(pipe)
					exit(1)
				}
			}
			close(scan_file_pipe)
		}
		close(pipe)
	}

	exit(0)
}


# vim:ts=4
