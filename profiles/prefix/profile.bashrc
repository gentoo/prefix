# Copyright 1999-2009 Gentoo Foundation; Distributed under the GPL v2
# $Id$

# Hack to avoid every package that uses libiconv/gettext
# install a charset.alias that will collide with libiconv's one
# See bugs 169678, 195148 and 256129.
# Also the discussion on
# http://archives.gentoo.org/gentoo-dev/msg_8cb1805411f37b4eb168a3e680e531f3.xml
post_src_install() {
	local f
	if [[ ${PN} != "libiconv" && -n $(ls "${ED}"/usr/lib*/charset.alias 2>/dev/null) ]]; then
		einfo "automatically removing charset.alias"
		rm -f "${ED}"/usr/lib*/charset.alias
	fi
}
