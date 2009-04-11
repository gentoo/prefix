# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/parrot/parrot-0.4.6.ebuild,v 1.2 2008/01/29 21:30:15 grobian Exp $

inherit base eutils multilib

DESCRIPTION="The virtual machine that perl6 relies on."
HOMEPAGE="http://www.parrotcode.org/"
SRC_URI="mirror://cpan/authors/id/CHIPS/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="gdbm gmp python test"

DEPEND="dev-lang/perl
		>=dev-libs/icu-2.6
		gdbm? ( >=sys-libs/gdbm-1.8.3-r1 )
		gmp? ( >=dev-libs/gmp-4.1.4 )
		python? ( >=dev-lang/python-2.3.4-r1  )
		"
		#java? ( >=dev-java/antlr-2.7.5 )

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/parrot-hints.patch
}

src_compile()	{
	#This configure defines the DESTDIR for make.
	perl Configure.pl --prefix="${EPREFIX}"/usr/$(get_libdir)/${P} || die "Perl ./Configure.pl failed"
	emake -j1 || die "emake failed"
}

src_install()	{

	#The prefix was set by Configure.pl - see src_compile().
	make install DESTDIR=${D} PREFIX="${EPREFIX}"/usr/$(get_libdir)/${P} || die
	dodir /usr/bin
	dosym /usr/$(get_libdir)/${P}/bin/parrot /usr/bin
	dosym /usr/$(get_libdir)/${P}/bin/parrot-config /usr/bin

	#copy some files especially for mod_parrot-0.2
	#maybe this should depend on a USE-Flag i.e. apache

	#install libparrot.a into /usr/lib/
	dolib.a blib/lib/*.a
	dolib.so blib/lib/*$(get_libname)*
	dosym /usr/$(get_libdir)/${P}/bin/parrot /usr/$(get_libdir)/${P}/parrot
	dosym /usr/$(get_libdir)/${P} /usr/$(get_libdir)/parrot

	#install libparrot.so.0.4.5 into /usr/$(get_libdir)/
	#MPC dosym /usr/$(get_libdir)/${p}/lib/libparrot.so.${pv} /usr/$(get_libdir)/libparrot.so.${pV}

	insinto /usr/$(get_libdir)/${P}
	doins config_lib.pasm

	#copy Header files - this should be done by "make install"
	dodir /usr/$(get_libdir)/${P}/include
	dodir /usr/$(get_libdir)/${P}/include/parrot
	insinto /usr/$(get_libdir)/${P}/include/parrot/
	doins ${S}/include/parrot/*.h

	#necessary for mod_parrot-0.3
	dodir /usr/$(get_libdir)/${P}/src/
	insinto /usr/$(get_libdir)/${P}/src/
	doins ${S}/src/parrot_config.o

	dodir /usr/share/doc/${P}
	dodoc README RESPONSIBLE_PARTIES ABI_CHANGES ChangeLog CREDITS NEWS
}

src_test()	{
	emake test || die "test failed"
}
