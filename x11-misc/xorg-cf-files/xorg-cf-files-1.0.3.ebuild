# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xorg-cf-files/xorg-cf-files-1.0.3.ebuild,v 1.9 2010/01/19 20:28:54 armin76 Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular eutils

DESCRIPTION="Old Imake-related build files"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_src_unpack
	cd "${S}"
	# switch to linux library model (stupid .sa files on Solaris...)
	epatch "${FILESDIR}"/${PN}-1.0.2-solaris-prefix.patch \
		"${FILESDIR}"/${PN}-1.0.3-x64-macos.patch
}

src_install() {
	x-modular_src_install
	echo "#define ManDirectoryRoot ${EPREFIX}/usr/share/man" >> ${ED}/usr/$(get_libdir)/X11/config/host.def
	sed -i -e "s/LibDirName *lib$/LibDirName $(get_libdir)/" "${ED}"/usr/$(get_libdir)/X11/config/Imake.tmpl || die "failed libdir sed"
	sed -i -e "s|LibDir Concat(ProjectRoot,/lib/X11)|LibDir Concat(ProjectRoot,/$(get_libdir)/X11)|" ${ED}/usr/$(get_libdir)/X11/config/X11.tmpl || die "failed libdir sed"
	sed -i -e "s|\(EtcX11Directory \)\(/etc/X11$\)|\1${EPREFIX}\2|" ${ED}/usr/$(get_libdir)/X11/config/X11.tmpl || die "failed etcx11dir sed"
	sed -i -e "/#  define Solaris64bitSubdir/d" ${ED}/usr/$(get_libdir)/X11/config/sun.cf
	sed -i -e 's/-DNOSTDHDRS//g' ${ED}/usr/$(get_libdir)/X11/config/sun.cf
}
