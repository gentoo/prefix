# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/bsdmk.eclass,v 1.6 2006/11/21 14:28:31 flameeyes Exp $
#
# Otavio R. Piske "AngusYoung" <angusyoung@gentoo.org>
# Diego Pettenò <flameeyes@gentoo.org>
# Benigno B. Junior <bbj@gentoo.org>

inherit toolchain-funcs portability flag-o-matic

EXPORT_FUNCTIONS src_compile src_install

RDEPEND=""
# this should actually be BDEPEND, but this works.
DEPEND="virtual/pmake"

ESED="/usr/bin/sed"

#### append-opt <options>
# append options to enable or disable features
#
###########################################################################
append-opt() {
	mymakeopts="${mymakeopts} $@"
}

#### mkmake <options>
# calls bsd-make command with the given options, passing ${mymakeopts} to
# enable ports to useflags bridge.
#
###########################################################################
mkmake() {
	[[ -z ${BMAKE} ]] && BMAKE="$(get_bmake)"

	tc-export CC CXX LD RANLIB

	${BMAKE} ${MAKEOPTS} ${EXTRA_EMAKE} ${mymakeopts} NO_WERROR= STRIP= "$@"
}

mkinstall() {
	[[ -z ${BMAKE} ]] && BMAKE="$(get_bmake)"

	# STRIP= will replace the default value of -s, leaving to portage the
	# task of stripping executables.
	${BMAKE} ${mymakeopts} NO_WERROR= STRIP= DESTDIR="${D}" "$@" install
}

#### dummy_mk <dirnames>
# removes the specified subdirectories and creates a dummy makefile in them
# useful to remove the need for "minimal" patches
#
############################################################################
dummy_mk() {
	for dir in $@; do
		echo ".include <bsd.lib.mk>" > ${dir}/Makefile
	done
}

#### fix_lazy_bindings <dirnames>
# set LDFLAGS in order to fix lazy binding warnings in binaries
#
############################################################################
fix_lazy_bindings() {
	for dir in $@; do
		echo "LDFLAGS+= $(bindnow-flags)" >> ${dir}/Makefile
	done
}

bsdmk_src_compile() {
	mkmake || die "make failed"
}

bsdmk_src_install() {
	mkinstall || die "install failed"
}
