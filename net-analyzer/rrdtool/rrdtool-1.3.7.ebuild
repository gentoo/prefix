# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/rrdtool/rrdtool-1.3.7.ebuild,v 1.1 2009/04/07 16:51:06 pva Exp $

EAPI=2

inherit eutils flag-o-matic multilib perl-module

DESCRIPTION="A system to store and display time-series data"
HOMEPAGE="http://oss.oetiker.ch/rrdtool/"
SRC_URI="http://oss.oetiker.ch/rrdtool/pub/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE="doc perl python ruby rrdcgi tcl"

# This versions are minimal versions upstream tested with.
RDEPEND="
	>=media-libs/libpng-1.2.10
	>=dev-libs/libxml2-2.6.31
	>=x11-libs/cairo-1.4.6[svg]
	>=dev-libs/glib-2.12.12
	>=x11-libs/pango-1.17
	tcl? ( dev-lang/tcl )
	perl? ( dev-lang/perl )
	python? ( dev-lang/python )
	ruby? ( dev-lang/ruby
			!dev-ruby/ruby-rrd )"

DEPEND="${RDEPEND}
	sys-apps/gawk"

pkg_setup() {
	use perl && perl-module_pkg_setup
}

src_configure() {
	filter-flags -ffast-math

	export RRDDOCDIR="${EPREFIX}"/usr/share/doc/${PF}

	# to solve bug #260380
	[[ ${CHOST} == *-solaris* ]] && append-flags -D__EXTENSIONS__

	econf $(use_enable rrdcgi) \
		$(use_enable ruby) \
		$(use_enable ruby ruby-site-install) \
		$(use_enable perl) \
		$(use_enable perl perl-site-install) \
		$(use_enable tcl) \
		$(use_with tcl tcllib "${EPREFIX}"/usr/$(get_libdir)) \
		$(use_enable python)
}

src_install() {
	# -j1 see bug #239101 for details
	emake -j1 DESTDIR="${D}" install || die "make install failed"

	if ! use doc ; then
		rm -rf "${ED}"/usr/share/doc/${PF}/{html,txt}
	fi

	use perl && fixlocalpod

	dodoc CHANGES CONTRIBUTORS NEWS README THREADS TODO
}

pkg_preinst() {
	use perl && perl-module_pkg_preinst
}

pkg_postinst() {
	use perl && perl-module_pkg_postinst
	ewarn "rrdtool dump 1.3 does emit completely legal xml. Basically this means that"
	ewarn "it contains an xml header and a DOCTYPE definition. Unfortunately this"
	ewarn "causes older versions of rrdtool restore to be unhappy."
	ewarn
	ewarn "To restore a new dump with ann old rrdtool restore version, either remove"
	ewarn "the xml header and the doctype by hand (both on the first line of the dump)"
	ewarn "or use rrdtool dump --no-header."
}

pkg_prerm() {
	use perl && perl-module_pkg_prerm
}

pkg_postrm() {
	use perl && perl-module_pkg_postrm
}
