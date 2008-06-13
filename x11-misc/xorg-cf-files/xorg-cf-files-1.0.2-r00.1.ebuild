# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xorg-cf-files/xorg-cf-files-1.0.2.ebuild,v 1.9 2007/02/20 00:07:12 blubb Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="Old Imake-related build files"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND=""
DEPEND=""

src_install() {
	x-modular_src_install
	echo "#define ManDirectoryRoot ${EPREFIX}/usr/share/man" >> ${ED}/usr/$(get_libdir)/X11/config/host.def
	sed -i -e "s/LibDirName *lib$/LibDirName $(get_libdir)/" ${ED}/usr/$(get_libdir)/X11/config/Imake.tmpl || die "failed libdir sed"
	sed -i -e "s|LibDir Concat(ProjectRoot,/lib/X11)|LibDir Concat(ProjectRoot,/$(get_libdir)/X11)|" ${ED}/usr/$(get_libdir)/X11/config/X11.tmpl || die "failed libdir sed"
	sed -i -e "s|\(EtcX11Directory \)\(/etc/X11$\)|\1${EPREFIX}\2|" ${ED}/usr/$(get_libdir)/X11/config/X11.tmpl || die "failed etcx11dir sed"
}
