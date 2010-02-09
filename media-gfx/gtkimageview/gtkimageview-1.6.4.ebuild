# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gtkimageview/gtkimageview-1.6.4.ebuild,v 1.20 2010/01/31 17:42:22 armin76 Exp $

EAPI="2"

inherit autotools gnome2 virtualx

DESCRIPTION="GtkImageView is a simple image viewer widget for GTK."
HOMEPAGE="http://trac.bjourne.webfactional.com/wiki"
SRC_URI="http://trac.bjourne.webfactional.com/attachment/wiki/WikiStart/${P}.tar.gz?format=raw -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="doc examples"

# tests do not work with userpriv
RESTRICT="userpriv"

RDEPEND=">=x11-libs/gtk+-2.6"
DEPEND="${DEPEND}
	gnome-base/gnome-common
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.8 )"

DOCS="README"

src_prepare() {
	gnome2_src_prepare

	# Prevent excessive build failures due to gcc changes
	sed -e '/CFLAGS/s/-Werror //g' -i configure.in || die "sed 1 failed"

	# Prevent excessive build failures due to glib/gtk changes
	sed '/DEPRECATED_FLAGS/d' -i configure.in || die "sed 2 failed"

	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=${EPREFIX}/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 3 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=true" \
			-i gtk-doc.make || die "sed 4 failed"
	fi

	eautoreconf
}

src_test() {
	# the tests are only built, but not run by default
	local failed="0"
	emake check || die "emake check failed"
	cd "${S}"/tests
	for test in test-* ; do
		if [[ -x ${test} ]] ; then
			./${test} || failed=$((${failed}+1))
		fi
	done
	[[ ${failed} -gt 0 ]] && die "${failed} tests failed"
}

src_install() {
	gnome2_src_install
	if use examples ; then
		docinto examples
		dodoc tests/ex-*.c || die "dodoc failed"
	fi
}
