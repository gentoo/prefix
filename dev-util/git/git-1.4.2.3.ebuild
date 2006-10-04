# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/git/git-1.4.2.3.ebuild,v 1.1 2006/10/02 19:21:29 ferdy Exp $

EAPI="prefix"

inherit python toolchain-funcs eutils elisp-common

DOC_VER=${PV}

DESCRIPTION="GIT - the stupid content tracker"
HOMEPAGE="http://kernel.org/pub/software/scm/git/"
SRC_URI="mirror://kernel/software/scm/git/${P}.tar.bz2
		mirror://kernel/software/scm/git/${PN}-manpages-${DOC_VER}.tar.bz2
		doc? ( mirror://kernel/software/scm/git/${PN}-htmldocs-${DOC_VER}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="curl doc emacs gtk mozsha1 ppcsha1 tk webdav"

DEPEND="dev-libs/openssl
		sys-libs/zlib
		!app-misc/git
		curl? ( net-misc/curl )
		webdav? ( dev-libs/expat )
		emacs? ( virtual/emacs )"
RDEPEND="${DEPEND}
		dev-lang/perl
		>=dev-lang/python-2.3
		app-text/rcs
		tk? ( dev-lang/tk )
		gtk? ( >=dev-python/pygtk-2.6 )"

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

	# Older python versions need own subproccess.py
	python_version
	[[ ${PYVER} < 2.4 ]] && myopts="${myopts} WITH_OWN_SUBPROCESS_PY=YesPlease"

	use elibc_uclibc && myopts="${myopts} NO_ICONV=YesPlease"

	export MY_MAKEOPTS=${myopts}
}

src_unpack() {
	unpack ${A}
	cd ${S}

	sed -i \
		-e "s:^\(CFLAGS = \).*$:\1${CFLAGS} -Wall:" \
		-e "s:^\(LDFLAGS = \).*$:\1${LDFLAGS}:" \
		-e "s:^\(CC = \).*$:\1$(tc-getCC):" \
		-e "s:^\(AR = \).*$:\1$(tc-getAR):" \
		Makefile || die "sed failed"

	exportmakeopts
}

src_compile() {
	emake ${MY_MAKEOPTS} DESTDIR="${EDEST}" prefix="${EPREFIX}"/usr || die "make failed"

	if use emacs ; then
		elisp-compile contrib/emacs/{,vc-}git.el || die "emacs modules failed"
	fi
}

src_install() {
	emake ${MY_MAKEOPTS} DESTDIR="${EDEST}" prefix="${EPREFIX}"/usr install || die "make install failed"

	use tk || rm "${D}"/usr/bin/gitk

	doman "${WORKDIR}"/man?/*

	dodoc README COPYING Documentation/SubmittingPatches
	if use doc ; then
		dodoc Documentation/technical/*
		dodir /usr/share/doc/${PF}/html
		cp -r "${WORKDIR}"/{*.html,howto} "${D}"/usr/share/doc/${PF}/html
	fi

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
}

src_test() {
	cd "${S}"

	has_version dev-util/subversion || \
		MY_MAKEOPTS="${MY_MAKEOPTS} NO_SVN_TESTS=YesPlease"
	emake ${MY_MAKEOPTS} DESTDIR="${EDEST}" prefix="${EPREFIX}"/usr test || die "tests failed"
}

pkg_postinst() {
	use emacs && elisp-site-regen
	einfo
	einfo "If you want to import arch repositories into git, consider using the"
	einfo "git-archimport command. You should install dev-util/tla before."
	einfo
	einfo "If you want to import cvs repositories into git, consider using the"
	einfo "git-cvsimport command. You should install >=dev-util/cvsps-2.1 before."
	einfo
	einfo "If you want to import svn repositories into git, consider using the"
	einfo "git-svnimport command. You should install dev-util/subversion before."
	einfo
	einfo "If you want to manage subversion repositories using git, consider"
	einfo "using git-svn. You should install dev-util/subversion and dev-perl/libwww-perl."
	einfo
	einfo "If you want to import a quilt series into git, consider using the"
	einfo "git-quiltimport command. You should install dev-util/quilt before."
	einfo
	einfo "If you want to use the included CVS server you will need to install"
	einfo "dev-perl/DBI and dev-perl/DBD-SQLite."
	einfo
}

pkg_postrm() {
	# regenerate site-gentoo if we are merged USE=emacs and unmerged
	# USE=-emacs
	has_version virtual/emacs && elisp-site-regen
}
