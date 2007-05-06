# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/git/git-1.5.1.3.ebuild,v 1.1 2007/05/01 03:17:06 robbat2 Exp $

EAPI="prefix"

inherit toolchain-funcs eutils elisp-common perl-module bash-completion

MY_PV="${PV/_rc/.rc}"
MY_P="${PN}-${MY_PV}"

DOC_VER=${MY_PV}

DESCRIPTION="GIT - the stupid content tracker"
HOMEPAGE="http://git.or.cz/"
SRC_URI="mirror://kernel/software/scm/git/${MY_P}.tar.bz2
		mirror://kernel/software/scm/git/${PN}-manpages-${DOC_VER}.tar.bz2
		doc? ( mirror://kernel/software/scm/git/${PN}-htmldocs-${DOC_VER}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="curl doc elibc_uclibc emacs gtk mozsha1 perl ppcsha1 tk webdav"

DEPEND="dev-libs/openssl
		sys-libs/zlib
		!app-misc/git
		curl? ( net-misc/curl )
		webdav? ( dev-libs/expat )
		emacs? ( virtual/emacs )
		virtual/libintl"
RDEPEND="${DEPEND}
		dev-lang/perl
		perl? ( dev-perl/Error )
		tk? ( dev-lang/tk )
		gtk? ( >=dev-python/pygtk-2.6 )"

S="${WORKDIR}/${MY_P}"

# This is needed because for some obscure reasons future calls to make don't
# pick up these exports if we export them in src_unpack()
exportmakeopts() {
	local myopts

	if use mozsha1 ; then
		myopts="${myopts} MOZILLA_SHA1=YesPlease"
	elif use ppcsha1 ; then
		myopts="${myopts} PPC_SHA1=YesPlease"
	fi

	if use curl ; then
		use webdav || myopts="${myopts} NO_EXPAT=YesPlease"
	else
		myopts="${myopts} NO_CURL=YesPlease"
		use webdav && ewarn "USE=webdav only matters with USE=curl. Ignoring."
	fi

	myopts="${myopts} WITH_SEND_EMAIL=YesPlease"
	# broken assumptions, because of broken build system ...
	myopts="${myopts} NO_FINK=YesPlease NO_DARWIN_PORTS=YesPlease"
	[[ ${CHOST} == *-solaris* ]] &&
		myopts="${myopts} NEEDS_LIBICONV=YesPlease INSTALL=install TAR=tar"

	use elibc_uclibc && myopts="${myopts} NO_ICONV=YesPlease"

	export MY_MAKEOPTS=${myopts}
}

showpkgdeps() {
	local pkg=$1
	shift
	elog "  $(printf "%-17s:" ${pkg}) ${@}"
}

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}"/${PN}-1.5.0-symlinks.patch

	sed -i \
		-e "s:^\(CFLAGS = \).*$:\1${CFLAGS} -Wall:" \
		-e "s:^\(LDFLAGS = \).*$:\1${LDFLAGS}:" \
		-e "s:^\(CC = \).*$:\1$(tc-getCC):" \
		-e "s:^\(AR = \).*$:\1$(tc-getAR):" \
		-e 's:ln :ln -s :g' \
		-e "s:\(PYTHON_PATH = \)\(.*\)$:\1${EPREFIX}\2:" \
		-e "s:\(PERL_PATH = \)\(.*\)$:\1${EPREFIX}\2:" \
		Makefile || die "sed failed"

	exportmakeopts
}

src_compile() {
	emake ${MY_MAKEOPTS} DESTDIR="${ED}" prefix="${EPREFIX}"/usr || die "make failed"

	if use emacs ; then
		elisp-compile contrib/emacs/{,vc-}git.el || die "emacs modules failed"
	fi
}

src_install() {
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr install || die "make install failed"

	use tk || rm "${ED}"/usr/bin/gitk

	doman "${WORKDIR}"/man?/*

	dodoc README COPYING Documentation/SubmittingPatches
	if use doc ; then
		dodoc Documentation/technical/*
		dodir /usr/share/doc/${PF}/html
		cp -r "${WORKDIR}"/{*.html,howto} "${ED}"/usr/share/doc/${PF}/html
	fi

	dobashcompletion contrib/completion/git-completion.bash ${PN}

	if use emacs ; then
		insinto "${SITELISP}"
		doins contrib/emacs/{,vc-}git.el*
		elisp-site-file-install "${FILESDIR}"/70git-gentoo.el
	fi

	if use gtk ; then
		dobin contrib/gitview/gitview
		use doc && dodoc contrib/gitview/gitview.txt
	fi

	insinto /etc/xinetd.d
	newins "${FILESDIR}"/git-daemon.xinetd git-daemon

	newinitd "${FILESDIR}"/git-daemon.initd git-daemon
	newconfd "${FILESDIR}"/git-daemon.confd git-daemon

	fixlocalpod
}

src_test() {
	cd "${S}"
	has_version dev-util/subversion || \
		MY_MAKEOPTS="${MY_MAKEOPTS} NO_SVN_TESTS=YesPlease"
	has_version app-arch/unzip || \
		rm "${S}"/t/t5000-tar-tree.sh
	# Stupid CVS won't let some people commit as root
	rm "${S}"/t/t9200-git-cvsexportcommit.sh
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr test || die "tests failed"
}

pkg_postinst() {
	use emacs && elisp-site-regen
	elog "These additional scripts need some dependencies:"
	echo
	showpkgdeps git-archimport "dev-util/tla"
	showpkgdeps git-cvsimport ">=dev-util/cvsps-2.1"
	showpkgdeps git-svnimport "dev-util/subversion(USE=perl)"
	showpkgdeps git-svn "dev-util/subversion(USE=perl)" "dev-perl/libwww-perl"
	showpkgdeps git-quiltimport "dev-util/quilt"
	showpkgdeps git-cvsserver "dev-perl/DBI" "dev-perl/DBD-SQLite"
	showpkgdeps git-instaweb "|| ( www-servers/lighttpd net-www/apache(SLOT=2) )"
	showpkgdeps git-send-email "USE=perl"
	showpkgdeps git-remote "USE=perl"
	echo
}

pkg_postrm() {
	# regenerate site-gentoo if we are merged USE=emacs and unmerged
	# USE=-emacs
	has_version virtual/emacs && elisp-site-regen
}
