# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/ccc.eclass,v 1.21 2009/02/08 17:16:02 vapier Exp $

# @ECLASS: ccc.eclass
# @MAINTAINER:
# alpha@gentoo.org
# @BLURB: functions to make ebuilds more ccc friendly.
#
# Authors:
# Tavis Ormandy <taviso@gentoo.org>
# Aron Griffis <agriffis@gentoo.org>

inherit flag-o-matic

# define this to make this eclass noisy.
#DEBUG_CCC_ECLASS=1

ccc-fixup()
{
	# helper function to fixup files
	# and show differences when debugging
	#
	# store the backup suffix.
	local files list suffix=ccc-fixup-${$}

	while read files
	do
		sed --in-place=.${suffix} ${1} ${files} || return 1
		list="${list} ${files}"
	done

	[ ! "$DEBUG_CCC_ECLASS" ] && return 0
	# if theres a backup, diff it.
	for i in ${list}
	do
		einfo "Checking for changes to `basename ${i}` ..."
		if [ -e "${i}.${suffix}" ]; then
			diff -u ${i}.${suffix} ${i}
#			sleep 1
		fi
	done
}

# @FUNCTION: hide-restrict-arr
# @DESCRIPTION:
# Scan for and replace __restrict_arr with a ccc
# supported equivalent.
#
# You might see an error like this if you need this:
# @CODE
# 	cc: Error: regexec.c, line 209: In the definition of the function "regexec",
# 	the promoted type of pmatch is incompatible with the type of the corresponding
# 	parameter in a prior declaration. (promotmatch)
# 	    regmatch_t pmatch[];
# 	    ---------------^
# @CODE
hide-restrict-arr()
{
	# __restrict_arr causes trouble with ccc, __restrict
	# is a supported equivalent.
	#
	# example:
	#           regmatch_t __pmatch[__restrict_arr]
	#

	find ${WORKDIR} -iname '*.h' | \
		xargs | ccc-fixup 's#\(\[__restrict\)_arr\]#\1\]#g'
}

# @FUNCTION: replace-cc-hardcode
# @DESCRIPTION:
# Look for common cc hardcodes in Makefiles.
replace-cc-hardcode()
{
	# lots of developers hardcode gcc into their
	# Makefiles. Try and fix these.
	#
	find ${WORKDIR} -iname Makefile | \
		xargs | ccc-fixup "s#^\(CC.*=\).*g\?cc#\1${CC:-gcc}#g"
}

# @FUNCTION: replace-cxx-hardcode
# @DESCRIPTION:
# Look for common cxx hardcodes in Makefiles.
replace-cxx-hardcode()
{
	# lots of developers hardcode g++ into thier
	# Makefiles. Try and fix these.
	find ${WORKDIR} -iname Makefile | \
		xargs | ccc-fixup "s#^\(CXX.*=\).*[gc]\{1\}++#\1${CXX:-g++}#g"
}

# @FUNCTION: is-ccc
# @RETURN: Returns success if dec compiler is being used.
# @DESCRIPTION:
# example:
#
# 	is-ccc && hide-restrict-arr
is-ccc()
{
	# return true if ccc is being used.
	[ "${ARCH}:`basename ${CC:-gcc}`" == "alpha:ccc" ]
}

# @FUNCTION: is-cxx
# @RETURN: Returns success if dec c++ compiler is being used.
is-cxx()
{
	# return true if cxx is being used
	[ "${ARCH}:`basename ${CXX:-g++}`" == "alpha:cxx" ]
}

# @FUNCTION: replace-ccc-g
# @DESCRIPTION:
# Try to replace -g with -g3
replace-ccc-g()
{
	# -g will stop ccc/cxx performing optimisation
	# replacing it with -g3 will let them co-exist.
	find ${WORKDIR} -iname Makefile | \
		xargs | ccc-fixup \
		"s#\(^\CX\{,2\}FLAGS[[:space:]]*=.*[\'\"\x20\t]*\)-g\([\'\"\x20\t]\|$\)#\1-g3\2#g"
	# FIXME: my eyes! it burns!
}

# @FUNCTION: ccc-elf-check
# @RETURN: Return success if binary was compiled with ccc
# @DESCRIPTION:
# example:
# @CODE
# 	if ! is-ccc; then
# 		ccc-elf-check /usr/lib/libglib.a && \
# 			append-ldflags -lots
# 	fi
# @CODE
#
# NOTE: i think the binary and shared library detection
# is pretty safe, but the archive detection may not
# be as reliable.
ccc-elf-check()
{
	# check if argument is a ccc created executable.
	# this is useful for libraries compiled with ccc,
	# which might require -lots/-lcpml if a linking binary
	# isnt being compiled with ccc.
	local myBINARY=${1:-a.out}
	if [[ ! "${myBINARY}" == *.a ]]; then
		# find the offset and size of the elf .note section.
		# example contents: 000132d2 00000dc8
		#                   ^- offset ^- size
		local elf_note_offset=`objdump -h ${myBINARY} | \
		grep -E '^\ [0-9]{2,}\ .note\ ' | \
			awk '{print $6,$3}' | \
			line`
		# check if that got anything.
		[ ! "${elf_note_offset}" ] && return 1
		# dump contents of section, and check for compaq signature.
		hexdump -s 0x${elf_note_offset% *} -n $((0x${elf_note_offset#* })) -e '"%_p"' ${myBINARY} | \
			grep -E 'Compaq Computer Corp.' &>/dev/null && return 0
		# no compaq message, return 1
	else
		# just grep it for the Compaq sig.
		hexdump -e '"%_p"' ${myBINARY} | \
			grep -E 'Compaq Computer Corp.' &>/dev/null && return 0
	fi
	return 1
}

# @FUNCTION: create-so
# @USAGE: < /usr/lib/library.a > < library.so >
# @DESCRIPTION:
# Make the shared library (.so) specified from the archive (.a)
# specified. LDFLAGS will be honoured. if you need a different
# `soname` (DT_SONAME) from the shared lib filename, you will have
# to do it manually ;)
#
# example:
# @CODE
# 	is-ccc && \
# 		create-so /usr/lib/libcoolstuff.a libcoolstuff.so.${PV}
# 	dosym /usr/lib/libcoolstuff.so.${PV} /usr/lib/libcoolstuff.so
# @CODE
#
# NOTE: -lots will be used by default, this is ccc.eclass after all :)
# NOTE: .${PV} is optional, of course.
# NOTE: dolib.so will manage installation
create-so()
{
	# some applications check for .so, but ccc wont
	# create one by default
	if [[ "${2}" == *.so ]]; then
	# no version suffix.
		${LD:-ld} -shared -o ${T}/${2##*/} -soname ${2##*/} \
			-whole-archive ${1} -no-whole-archive -lots ${LDFLAGS}
	else
	# version suffix
		local so_version=${2##*.so}
		${LD:-ld} -shared -o ${T}/${2##*/} -soname `basename ${2/${so_version}}` \
				-whole-archive ${1} -no-whole-archive -lots ${LDFLAGS}
	fi
	# hand installation over to dolib.so
	dolib.so ${T}/${2##*/}
}

# @FUNCTION: otsify
# @USAGE: < archive >
# @DESCRIPTION:
# Add the functions from libots to <archive>, this means
# that if you use gcc to build an application that links with
# <archive>, you wont need -lots.
# Use this on libraries that you want maximum performance from,
# but might not be using ccc when linking against it (eg zlib, openssl, etc)
#
# example:
# 
# 	is-ccc && otsify ${S}/libz.a
otsify()
{
	[ "$DEBUG_CCC_ECLASS" ] && local ar_args="v"

	# confirm argument exists, and is an archive (eg *.a)
	# if it is, extract libots members into tempdir, then
	# append them to argument, regenerate index and then return.

	if [ "${1##*.}" == "a" ] && [ -f "${1}" ]; then
		einfo "otsifying `basename ${1}` ..."

		mkdir ${T}/ccc-otsify-${$}
		cd ${T}/ccc-otsify-${$}

		einfo "	extracting archive members from libots ..."
		ar ${ar_args}x /usr/lib/libots.a || {
			eerror "	unable to extract libots members."
			return 1
		}

		einfo "	appending libots members to `basename ${1}` ..."
		ar ${ar_args}q ${1} ${T}/ccc-otsify-${$}/*.o || {
			eerror "	failed to append libots members to ${1}."
			return 1
		}

		einfo  "	regenerating `basename ${1}` archive index ..."
		ranlib ${1} || ewarn "	ranlib returned an error, probably not important."
		einfo "otsification completed succesfully."
		cd ${OLDPWD:-.}
		return 0
	else
		ewarn "called otsify() with bad argument ..."
		cd ${OLDPWD:-.}
		return 1
	fi
}
