# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/parrot/parrot-0.6.1.ebuild,v 1.1 2008/04/29 01:29:11 yuval Exp $

inherit base eutils multilib

DESCRIPTION="The virtual machine that perl6 relies on."
HOMEPAGE="http://www.parrotcode.org/"
SRC_URI="mirror://cpan/authors/id/P/PA/PARTICLE/${P}.tar.gz"
LICENSE="|| ( Artistic GPL-2 )"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc examples gdbm gmp python"

RDEPEND=">=dev-libs/icu-2.6
		>=sys-libs/ncurses-5.2-r2
		>=sys-libs/readline-5.1
		gdbm? ( >=sys-libs/gdbm-1.8.3-r1 )
		gmp? ( >=dev-libs/gmp-4.1.4 )"

DEPEND="${RDEPEND}
		dev-lang/perl
		python? ( =dev-lang/python-2.4* )"
		#java? ( >=dev-java/antlr-2.7.5 )

src_compile() {
	#This configure defines the DESTDIR for make.
	perl Configure.pl --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die "Perl ./Configure.pl failed"
	emake -j1 || die "emake failed"
	if use doc ; then
		emake html || die "emake html failed"
	fi
}

src_install() {
	#Don't install stuff that is unnecessary
	#We can't do this in src_unpack() because it breaks emake html
	sed -e '/^\(docs\/\|LICENSES\|TODO\|compilers\|config\)/ D' -i MANIFEST
	sed -e '/^\(docs\/\|compilers\|config\)/ D' -i MANIFEST.generated
	sed -e '/^src.*\[main\]$/ D' -i MANIFEST.generated
	if ! use examples ; then
		sed -e '/^examples\// D' -i MANIFEST
		sed -e '/^examples\// D' -i MANIFEST.generated
	fi
	#Because install_files.pl doesn't respect LIB_DIR in some places
	sed -e "s:/lib/:/$(get_libdir)/:" -i tools/dev/install_files.pl
	#The prefix was set by Configure.pl - see src_compile().
	emake -j1 reallyinstall DESTDIR="${D}" DOC_DIR="${EPREFIX}/usr/share/doc/${P}" || die "emake install failed"
	insinto "/usr/$(get_libdir)/${PN}"
	doins config_lib.pasm

	#necessary for mod_parrot-0.3
	dodir "/usr/$(get_libdir)/${PN}/src/"
	insinto "/usr/$(get_libdir)/${PN}/src/"
	doins "${S}/src/install_config.o" "${S}/src/null_config.o" "${S}/src/parrot_config.o"

	pod2html DEPRECATED.pod > DEPRECATED.html
	dodoc README RESPONSIBLE_PARTIES ABI_CHANGES ChangeLog CREDITS NEWS \
		DEPRECATED.html
	use doc && dohtml -r docs/html/*
}

src_test() {
	emake test || die "test failed"
}
