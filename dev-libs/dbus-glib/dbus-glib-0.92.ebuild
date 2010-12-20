# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.92.ebuild,v 1.1 2010/11/10 16:49:58 ssuominen Exp $

EAPI=2
inherit bash-completion

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bash-completion debug doc static-libs test"

RDEPEND=">=sys-apps/dbus-1.1
	>=dev-libs/glib-2.26
	>=dev-libs/expat-1.95.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	doc? (
		app-doc/doxygen
		app-text/xmlto
		>=dev-util/gtk-doc-1.4 )"

# out of sources build directory
BD=${WORKDIR}/${P}-build
# out of sources build dir for make check
TBD=${WORKDIR}/${P}-tests-build

BASHCOMPLETION_NAME="dbus"

src_configure() {
	local my_conf

	my_conf="--localstatedir=${EPREFIX}/var
		$(use_enable bash-completion)
		$(use_enable debug verbose-mode)
		$(use_enable debug asserts)
		$(use_enable doc doxygen-docs)
		$(use_enable static-libs static)
		$(use_enable doc gtk-doc)
		--with-html-dir=${EPREFIX}/usr/share/doc/${PF}/html"

	mkdir "${BD}"
	cd "${BD}"
	einfo "Running configure in ${BD}"
	ECONF_SOURCE="${S}" econf ${my_conf}

	if use test; then
		mkdir "${TBD}"
		cd "${TBD}"
		einfo "Running configure in ${TBD}"
		ECONF_SOURCE="${S}" econf \
			${my_conf} \
			$(use_enable test checks) \
			$(use_enable test tests) \
			$(use_enable test asserts) \
			$(use_with test test-socket-dir "${T}"/dbus-test-socket)
	fi
}

src_compile() {
	cd "${BD}"
	einfo "Running make in ${BD}"
	emake || die

	if use test; then
		cd "${TBD}"
		einfo "Running make in ${TBD}"
		emake || die
	fi
}

src_test() {
	cd "${TBD}"
	emake check || die
}

src_install() {
	dodoc AUTHORS ChangeLog HACKING NEWS README || die

	cd "${BD}"
	emake DESTDIR="${D}" install || die

	# FIXME: We need --with-bash-completion-dir
	if use bash-completion ; then
		dobashcompletion "${ED}"/etc/bash_completion.d/dbus-bash-completion.sh
		rm -rf "${ED}"/etc/bash_completion.d || die
	fi

	find "${ED}" -name '*.la' -exec rm -f '{}' +
}
