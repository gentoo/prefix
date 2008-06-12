# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/svk/svk-1.08.ebuild,v 1.3 2007/07/12 01:05:42 mr_bones_ Exp $

EAPI="prefix"

inherit eutils perl-module bash-completion

MY_P=${P/svk/SVK}
S=${WORKDIR}/${MY_P}

DESCRIPTION="A decentralized version control system"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${MY_P}.tar.gz"
HOMEPAGE="http://svk.elixus.org/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="crypt nls pager patch"

DEPEND="
	>=dev-lang/perl-5.8.7
	>=dev-util/subversion-1.0.7
	dev-perl/Algorithm-Annotate
	dev-perl/Algorithm-Diff
	>=dev-perl/yaml-0.38
	dev-perl/Regexp-Shellish
	>=dev-perl/Data-Hierarchy-0.21
	>=virtual/perl-File-Temp-0.14
	dev-perl/Clone
	dev-perl/Pod-Escapes
	dev-perl/Pod-Simple
	>=dev-perl/PerlIO-via-dynamic-0.11
	>=dev-perl/PerlIO-via-symlink-0.02
	dev-perl/IO-Digest
	>=dev-perl/SVN-Simple-0.27
	>=dev-perl/TimeDate-1.16
	dev-perl/TermReadKey
	dev-perl/File-Type
	dev-perl/URI
	>=dev-perl/PerlIO-eol-0.13
	>=dev-perl/Class-Autouse-1.15
	>=virtual/perl-Getopt-Long-2.34
	>=virtual/perl-File-Spec-3.18
	>=dev-perl/SVN-Mirror-0.66
	nls? (
		>=dev-perl/locale-maketext-lexicon-0.42
		>=dev-perl/Locale-Maketext-Simple-0.12
	)
	pager? ( dev-perl/IO-Pager )
	>=dev-perl/SVN-Mirror-0.66
	patch? (
		dev-perl/Compress-Zlib
		dev-perl/FreezeThaw
	)
	crypt? ( app-crypt/gnupg )"
RDEPEND="${DEPEND}"

pkg_setup() {
	if ! perl -MSVN::Core < /dev/null 2> /dev/null; then
		eerror "SVN::Core missing or outdated. Please emerge \
		dev-util/subversion ith the perl USE flag."
		die "Need Subversion compiled with Perl bindings"
	fi
}

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/svk-1.08-xxdiff.patch
}

src_install() {
	perl-module_src_install
	if use bash-completion; then
		dobin contrib/svk-completion.pl
		echo "complete -C ${DESTTREE}/bin/svk-completion.pl -o default svk" \
			> svk-completion
		dobashcompletion svk-completion
	fi
}
