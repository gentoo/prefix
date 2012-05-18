# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libprelude/libprelude-1.0.0-r1.ebuild,v 1.11 2012/04/07 17:56:09 maekke Exp $

EAPI="3"
GENTOO_DEPEND_ON_PERL="no"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit autotools distutils eutils flag-o-matic multilib perl-module

DESCRIPTION="Prelude-IDS Framework Library"
HOMEPAGE="http://www.prelude-technologies.com"
SRC_URI="${HOMEPAGE}/download/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc lua perl python ruby"

RDEPEND=">=net-libs/gnutls-1.0.17
	lua? ( dev-lang/lua )
	perl? ( dev-lang/perl )
	ruby? ( dev-lang/ruby )
	!net-analyzer/prelude-nids"
DEPEND="${RDEPEND}
	sys-devel/flex
	perl? ( dev-lang/swig )"

DISTUTILS_SETUP_FILES=("bindings/low-level/python|setup.py" "bindings/python|setup.py")
PYTHON_MODNAME="prelude.py PreludeEasy.py"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-libtool.patch
	epatch "${FILESDIR}"/${P}-ruby.patch

	# Avoid null runpaths in Perl bindings.
	sed -e 's/ LD_RUN_PATH=""//' -i bindings/Makefile.am bindings/low-level/Makefile.am || die "sed failed"

	# Python bindings are built/installed manually.
	sed -e "/^SUBDIRS =/s/ python//" -i bindings/low-level/Makefile.am bindings/Makefile.am || die "sed failed"

	eautoreconf
}

src_configure() {
	filter-lfs-flags

	# SWIG is needed to build Perl high-level bindings.
	econf \
		--enable-easy-bindings \
		$(use_enable doc gtk-doc) \
		$(use_with lua) \
		$(use_with perl) \
		$(use_with perl swig) \
		$(use_with python) \
		$(use_with ruby)
}

src_compile() {
	emake OTHERLDFLAGS="${LDFLAGS}" || die "emake failed"

	if use python; then
		distutils_src_compile
	fi
}

src_install() {
	emake DESTDIR="${D}" INSTALLDIRS=vendor install || die "make install failed"

	if use lua; then
		rm -f "${ED}usr/$(get_libdir)/PreludeEasy.la"
	fi

	if use perl; then
		perl_delete_localpod
		perl_delete_packlist
	fi

	if use python; then
		distutils_src_install
	fi

	if use ruby; then
		find "${ED}/usr/$(get_libdir)/ruby" -name "*.la" -print0 | xargs -0 rm -f
	fi
}

pkg_postinst() {
	if use python; then
		distutils_pkg_postinst
	fi
}

pkg_postrm() {
	if use python; then
		distutils_pkg_postrm
	fi
}
