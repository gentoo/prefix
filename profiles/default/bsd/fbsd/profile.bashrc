#!/bin/bash
# Copyright 1999-2009 Gentoo Foundation; Distributed under the GPL v2
# $Header: /var/cvsroot/gentoo-x86/profiles/default/bsd/fbsd/profile.bashrc,v 1.4 2009/03/11 14:43:09 drizzt Exp $

alias make=gmake
alias patch=gpatch
alias sed=gsed
alias awk=gawk

# Hack to avoid every package that uses libiconv/gettext
# install a charset.alias that will collide with libiconv's one
# See bugs 169678, 195148 and 256129.
# Also the discussion on
# http://archives.gentoo.org/gentoo-dev/msg_8cb1805411f37b4eb168a3e680e531f3.xml
post_src_install()
{
	if [ "${PN}" != "libiconv" -a -e "${D}"/usr/lib*/charset.alias ] ; then
		rm -f "${D}"/usr/lib*/charset.alias
	fi
}
