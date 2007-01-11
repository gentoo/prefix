# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/debug.eclass,v 1.35 2007/01/07 00:41:55 flameeyes Exp $

# STOP USING THIS ECLASS
# It was broken, and debug useflag should _not_ touch CFLAGS to start with.
# See http://bugs.gentoo.org/show_bug.cgi?id=55708 for info about this
# and http://www.gentoo.org/proj/en/qa/backtraces.xml to learn how to get
# a debug build.
if [[ ${EBUILD_PHASE} != *rm ]]; then
	ewarn "QA Notice: The package ${CATEGORY}/${PF} still uses the broken debug.eclass"
fi
