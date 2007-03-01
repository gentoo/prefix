# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/xemacs-packages.eclass,v 1.12 2007/02/23 19:50:03 graaff Exp $
#
# xemacs-packages eclass inherited by all xemacs packages
# $PKG_CAT need's to be set before inheriting xemacs-packages

INHERITED="$INHERITED $ECLASS"

EXPORT_FUNCTIONS src_unpack src_compile src_install

DEPEND="virtual/xemacs"

[ -z "$HOMEPAGE" ]    && HOMEPAGE="http://xemacs.org/"
[ -z "$LICENSE" ]     && LICENSE="GPL-2"

case "${PKG_CAT}" in
	"standard" )
		MY_INSTALL_DIR="/usr/lib/xemacs/xemacs-packages" ;;

	"mule" )
		MY_INSTALL_DIR="/usr/lib/xemacs/mule-packages" ;;

	"contrib" )
		MY_INSTALL_DIR="/usr/lib/xemacs/site-packages" ;;
esac
[ -n "$DEBUG" ] && einfo "MY_INSTALL_DIR is ${MY_INSTALL_DIR}"

if [ -n "$EXPERIMENTAL" ]
then
	[ -z "$SRC_URI" ] && SRC_URI="ftp://ftp.xemacs.org/beta/experimental/packages/${P}-pkg.tar.gz"
else
	[ -z "$SRC_URI" ] && SRC_URI="http://ftp.xemacs.org/pub/xemacs/packages/${P}-pkg.tar.gz"
fi
[ -n "$DEBUG" ] && einfo "SRC_URI is ${SRC_URI}"

xemacs-packages_src_unpack() {
	return 0
}

xemacs-packages_src_compile() {
	einfo "Nothing to compile"
}

xemacs-packages_src_install() {
	dodir ${MY_INSTALL_DIR}
	cd ${D}${MY_INSTALL_DIR}
	unpack ${A}
}
