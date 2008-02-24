# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.2.3-r9.ebuild,v 1.17 2008/02/23 19:11:23 ulm Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.6"

inherit eutils libtool flag-o-matic multilib autotools

MY_P=${P/m/M}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Open Motif"
HOMEPAGE="http://www.motifzone.org/"
SRC_URI="ftp://ftp.motifzone.net/om${PV}/src/${MY_P}.tar.gz
	mirror://gentoo/${P}-patches-1.tar.bz2"

LICENSE="MOTIF"
SLOT="2.2"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="
	x11-libs/libXmu
	x11-libs/libXaw
	x11-libs/libXp
	x11-proto/printproto
	>=x11-libs/motif-config-0.9"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4
	x11-misc/xbitmaps"

PROVIDE="virtual/motif"

pkg_setup() {
	# multilib includes don't work right in this package...
	[ -n "${ABI}" ] && append-flags "-I${EPREFIX}/usr/include/gentoo-multilib/${ABI}"
}

src_unpack() {
	unpack ${A}
	cd ${S}

	# various patches
	EPATCH_SUFFIX=patch epatch

	# This replaces deprecated, obsoleted and now invalid AC_DEFINE
	# with their proper alternatives.
	sed -i -e 's:AC_DEFINE(\([^)]*\)):AC_DEFINE(\1, [], [\1]):g' \
		"${S}/configure.in" "${S}/acinclude.m4"

	eautoreconf
}

src_compile() {
	# get around some LANG problems in make (#15119)
	unset LANG

	# bug #80421
	filter-flags -ftracer

	append-flags -fno-strict-aliasing

	econf --with-x || die "configuration failed"

	emake -j1 || die "make failed, if you have lesstif installed removed it, compile openmotif and recompile lesstif"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"

	# cleanups
	rm -fR ${ED}/usr/$(get_libdir)/X11
	rm -fR ${ED}/usr/$(get_libdir)/X11/bindings
	rm -fR ${ED}/usr/include/X11/

	list="/usr/share/man/man1/mwm.1 /usr/share/man/man4/mwmrc.4"
	for f in $list; do
		dosed 's:/usr/lib/X11/\(.*system\\&\.mwmrc\):${EPREFIX}/etc/X11/mwm/\1:g' "$f"
		dosed 's:/usr/lib/X11/app-defaults:${EPREFIX}/etc/X11/app-defaults:g' "$f"
	done

	einfo "Fixing binaries"
	dodir /usr/$(get_libdir)/openmotif-2.2
	for file in `ls ${ED}/usr/bin`
	do
		mv ${ED}/usr/bin/${file} ${ED}/usr/$(get_libdir)/openmotif-2.2/${file}
	done

	einfo "Fixing libraries"
	mv ${ED}/usr/$(get_libdir)/* ${ED}/usr/$(get_libdir)/openmotif-2.2/

	einfo "Fixing includes"
	dodir /usr/include/openmotif-2.2/
	mv ${ED}/usr/include/* ${ED}/usr/include/openmotif-2.2

	einfo "Fixing man pages"
	mans="1 3 4 5"
	for man in $mans; do
		dodir /usr/share/man/man${man}
		for file in `ls ${ED}/usr/share/man/man${man}`
		do
			file=${file/.${man}/}
			mv ${ED}/usr/share/man/man$man/${file}.${man} ${ED}/usr/share/man/man${man}/${file}-openmotif-2.2.${man}
		done
	done

	# install docs
	dodoc README RELEASE RELNOTES BUGREPORT TODO

	# profile stuff
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/openmotif-2.2" > ${ED}/etc/env.d/15openmotif-2.2
	dodir /usr/$(get_libdir)/motif
	echo "PROFILE=openmotif-2.2" > ${ED}/usr/$(get_libdir)/motif/openmotif-2.2
}

pkg_postinst() {
	"${EROOT}"/usr/bin/motif-config -s
}

pkg_postrm() {
	"${EROOT}"/usr/bin/motif-config -s
}
