# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/svk/svk-2.0.2.ebuild,v 1.5 2009/04/25 07:57:47 patrick Exp $

EAPI=2

inherit eutils perl-module bash-completion

MY_PV="v${PV}"
MY_P="${PN/svk/SVK}-${MY_PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A decentralized version control system"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${MY_P}.tar.gz"
HOMEPAGE="http://svk.elixus.org/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="crypt nls pager patch log4p bash-completion"

DEPEND="
	>=dev-lang/perl-5.8.7
	>=dev-util/subversion-1.3.0[perl]
	virtual/perl-version
	dev-perl/Algorithm-Annotate
	>=dev-perl/Algorithm-Diff-1.1901
	>=dev-perl/YAML-Syck-0.60
	>=dev-perl/Data-Hierarchy-0.30
	>=dev-perl/PerlIO-via-dynamic-0.11
	>=dev-perl/PerlIO-via-symlink-0.02
	dev-perl/IO-Digest
	>=dev-perl/SVN-Simple-0.27
	dev-perl/URI
	>=dev-perl/PerlIO-eol-0.13
	>=dev-perl/Class-Autouse-1.15
	dev-perl/App-CLI
	dev-perl/List-MoreUtils
	dev-perl/Class-Accessor
	dev-perl/Class-Data-Inheritable
	>=dev-perl/Path-Class-0.16
	dev-perl/UNIVERSAL-require
	dev-perl/TermReadKey
	>=virtual/perl-File-Temp-0.17
	>=virtual/perl-Getopt-Long-2.35
	virtual/perl-Pod-Escapes
	virtual/perl-Pod-Simple
	>=virtual/perl-File-Spec-3.19
	nls? (
		>=dev-perl/locale-maketext-lexicon-0.62
		virtual/perl-Locale-Maketext-Simple
	)
	pager? ( dev-perl/IO-Pager )
	log4p? ( dev-perl/Log-Log4perl )
	>=dev-perl/SVN-Mirror-0.71
	patch? (
		virtual/perl-Compress-Zlib
		dev-perl/FreezeThaw
	)
	crypt? ( app-crypt/gnupg )
	dev-perl/TimeDate"
RDEPEND="${DEPEND}"

src_install() {
	perl-module_src_install
	if use bash-completion; then
		dobin contrib/svk-completion.pl
		echo "complete -C ${DESTTREE}/bin/svk-completion.pl -o default svk" \
			> svk-completion
		dobashcompletion svk-completion
	fi
}
