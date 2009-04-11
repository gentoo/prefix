# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-misc/tinysvm/tinysvm-0.09-r2.ebuild,v 1.1 2008/11/03 01:20:20 matsuu Exp $

inherit eutils perl-module toolchain-funcs autotools

MY_P="TinySVM-${PV}"
DESCRIPTION="TinySVM is an implementation of Support Vector Machines (SVMs) for
pattern recognition."
HOMEPAGE="http://chasen.org/~taku/software/TinySVM/"
SRC_URI="http://chasen.org/~taku/software/TinySVM/src/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
#IUSE="java perl python ruby"
IUSE="perl"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PF}-pm.patch"
	ln -s . src/TinySVM

	epatch ${FILESDIR}/${P}-darwin.patch
	eautoreconf # need new libtool on Darwin
}

src_compile() {
	tc-export CC CXX

	econf || die
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" || die
	if use perl ; then
		(
			cd perl
			perl-module_src_compile || die "compile failed in perl"
		)
	fi
	## currently it fails to compile under python-2.4
	#if use python ; then
	#	(
	#		cd python
	#		emake -f Makefile.pre.in boot || die "compile failed in python"
	#		emake || die
	#	)
	#fi
	## currently it fails to compile under gcc-3.4
	#if use ruby ; then
	#	(
	#		cd ruby
	#		ruby extconf.rb || die
	#		emake || die
	#	)
	#fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS README THANKS

	if use perl ; then
		(
			cd perl
			perl-module_src_install || die "install failed in perl"
		)
	fi
	#if use python ; then
	#	(
	#		cd python
	#		emake DESTDIR="${D}" install || die "install failed in python"
	#	)
	#fi
	#if use ruby ; then
	#	(
	#		cd ruby
	#		emake DESTDIR="${D}" install || die "install failed in ruby"
	#	)
	#fi
}
