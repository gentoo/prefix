# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-1.17.ebuild,v 1.11 2008/04/20 17:01:55 flameeyes Exp $

inherit libtool eutils multilib

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="http://www.littlecms.com/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="tiff jpeg zlib python"

RDEPEND="tiff? ( media-libs/tiff )
	jpeg? ( media-libs/jpeg )
	zlib? ( sys-libs/zlib )
	python? ( >=dev-lang/python-1.5.2 )"
		# ugly workaround because arches have not keyworded it
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-1.3.31 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix multilib-strict; bug #185294
#	epatch "${FILESDIR}"/${P}-multilib.patch
	# use sed expression due to bug #228711
	sed -i -e '/LCMS_PYEXECDIR=/s/sysconfig\.get_python_lib()/sysconfig.get_python_lib(True)/g' configure{.ac,}

	elibtoolize

	# run swig to regenerate lcms_wrap.cxx and lcms.py (bug #148728)
	if use python; then
		cd "${S}"/python
		./swig_lcms || die "swig_lcms failed"
	fi
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_with zlib) \
		$(use_with python) \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${ED}"/usr/bin \
		libdir="${EPREFIX}"/usr/$(get_libdir) \
		install || die "make install failed"

	insinto /usr/share/lcms/profiles
	doins testbed/*.icm

	dodoc AUTHORS README* INSTALL NEWS doc/*
}
