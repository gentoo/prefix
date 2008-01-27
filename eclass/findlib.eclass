# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/findlib.eclass,v 1.5 2005/07/11 15:08:06 swegener Exp $
#
# Author : Matthieu Sozeau <mattam@gentoo.org>
#
# ocamlfind (a.k.a. findlib) eclass
#


# From this findlib version there is proper stublibs support.
DEPEND=">=dev-ml/findlib-1.0.4-r1"

check_ocamlfind() {
	if [ ! -x "${EPREFIX}"/usr/bin/ocamlfind ]
	then
		ewarn "In findlib.eclass: could not find the ocamlfind executable"
		ewarn "Please report this bug on gentoo's bugzilla, assigning to ml@gentoo.org"
		exit 1
	fi
}

# Prepare the image for a findlib installation.
# We use the stublibs style, so no ld.conf needs to be
# updated when a package installs C shared libraries.
findlib_src_preinst() {
	check_ocamlfind

	# destdir is the ocaml sitelib
	local destdir=`ocamlfind printconf destdir`

	# strip off prefix
	destdir=${destdir#${EPREFIX}}

	dodir ${destdir} || die "dodir failed"
	export OCAMLFIND_DESTDIR=${ED}${destdir}

	# stublibs style
	dodir ${destdir}/stublibs || die "dodir failed"
	export OCAMLFIND_LDCONF=ignore
}

# Install with a properly setup findlib
findlib_src_install() {
	findlib_src_preinst
	make DESTDIR=${D} "$@" install || die "make failed"
}
