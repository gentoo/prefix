# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/git/git-1.5.3.7-r1.ebuild,v 1.3 2007/12/06 04:46:48 mr_bones_ Exp $

EAPI="prefix"

inherit toolchain-funcs eutils elisp-common perl-module bash-completion

MY_PV="${PV/_rc/.rc}"
MY_P="${PN}-${MY_PV}"

DOC_VER=${MY_PV}

DESCRIPTION="GIT - the stupid content tracker, the revision control system heavily used by the Linux kernel team"
HOMEPAGE="http://git.or.cz/"
SRC_URI="mirror://kernel/software/scm/git/${MY_P}.tar.bz2
		mirror://kernel/software/scm/git/${PN}-manpages-${DOC_VER}.tar.bz2
		doc? ( mirror://kernel/software/scm/git/${PN}-htmldocs-${DOC_VER}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="curl cgi doc emacs gtk iconv mozsha1 perl ppcsha1 tk webdav"

DEPEND="
	!app-misc/git
	dev-libs/openssl
	sys-libs/zlib
	dev-lang/perl
	app-arch/cpio
	tk?     ( dev-lang/tk )
	curl?   ( net-misc/curl )
	webdav? ( dev-libs/expat )
	emacs?  ( virtual/emacs )"
RDEPEND="${DEPEND}
	cgi?	( virtual/perl-CGI )
	perl?   ( dev-perl/Error )
	gtk?    ( >=dev-python/pygtk-2.8 )"

SITEFILE=72${PN}-gentoo.el
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

	use iconv || myopts="${myopts} NO_ICONV=YesPlease"

	export MY_MAKEOPTS=${myopts}
}

showpkgdeps() {
	local pkg=$1
	shift
	elog "  $(printf "%-17s:" ${pkg}) ${@}"
}

src_unpack() {
	unpack ${MY_P}.tar.bz2
	cd "${S}"
	unpack ${PN}-manpages-${DOC_VER}.tar.bz2
	use doc && cd "${S}"/Documentation && unpack ${PN}-htmldocs-${DOC_VER}.tar.bz2
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.5.3-symlinks.patch

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
	emake ${MY_MAKEOPTS} DESTDIR="${ED}" prefix="${EPREFIX}"/usr || \
		die "make failed"

	if use emacs ; then
		elisp-compile contrib/emacs/{,vc-}git.el || die "emacs modules failed"
	fi
	if use cgi ; then
		emake ${MY_MAKEOPTS} \
		DESTDIR="${ED}" \
		prefix=/usr \
		gitweb/gitweb.cgi || die "make gitweb/gitweb.cgi failed"
	fi
}

src_install() {
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr install || die "make install failed"

	use tk || rm "${ED}"/usr/bin/git{k,-gui}

	doman man?/*

	dodoc README Documentation/{SubmittingPatches,CodingGuidelines}
	use doc && dodir /usr/share/doc/${PF}/html
	for d in / /howto/ /technical/ ; do
		einfo "Doing Documentation${d}"
		docinto ${d}
		dodoc Documentation${d}*.txt
		use doc && dohtml -p ${d} Documentation${d}*.html
	done
	docinto /

	dobashcompletion contrib/completion/git-completion.bash ${PN}

	if use emacs ; then
		elisp-install ${PN} contrib/emacs/{,vc-}git.el* || \
			die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
		# don't add automatically to the load-path, so the sitefile
		# can do a conditional loading
		touch "${ED}"/"${SITELISP}"/${PN}/.nosearch
	fi

	if use gtk ; then
		dobin "${S}"/contrib/gitview/gitview
		dodoc "${S}"/contrib/gitview/gitview.txt
		newbin "${S}"/contrib/blameview/blameview.perl blameview
		newdoc "${S}"/contrib/blameview/README README.blameview
	fi

	dodir /usr/share/${PN}/contrib
	for i in continuous fast-import hg-to-git \
		hooks remotes2config.sh vim stats \
		workdir ; do
		cp -rf \
			"${S}"/contrib/${i} \
			"${ED}"/usr/share/${PN}/contrib \
			|| die "Failed contrib ${i}"
	done

	if use cgi ; then
		dodir /usr/share/${PN}/gitweb
		insinto /usr/share/${PN}/gitweb
		doins "${S}"/gitweb/gitweb.{cgi,css}
		doins "${S}"/gitweb/git-{favicon,logo}.png
		docinto /
		# INSTALL discusses configuration issues, not just installation
		newdoc  "${S}"/gitweb/INSTALL INSTALL.gitweb
		newdoc  "${S}"/gitweb/README README.gitweb
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
	if has userpriv "${FEATURES}"; then
		einfo "Enabling CVS tests as we have FEATURES=userpriv"
	else
		ewarn "Skipping CVS tests because CVS does not work as root!"
		ewarn "You should retest with FEATURES=userpriv!"
		for i in t9200-git-cvsexportcommit.sh t9600-cvsimport.sh ; do
			rm "${S}"/t/${i} || die "Failed to remove ${i}"
		done
	fi
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr test || die "tests failed"
}

pkg_postinst() {
	if use emacs ; then
		elisp-site-regen
		elog "GNU Emacs has built-in Git support in versions greater 22.1."
		elog "You can disable the emacs USE flag for dev-util/git"
		elog "if you are using such a version."
	fi
	elog "These additional scripts need some dependencies:"
	elog "(These are also needed for FEATURES=test)"
	echo
	showpkgdeps git-archimport "dev-util/tla"
	showpkgdeps git-cvsimport ">=dev-util/cvsps-2.1"
	showpkgdeps git-svnimport "dev-util/subversion(USE=perl)"
	showpkgdeps git-svn \
		"dev-util/subversion(USE=perl)" \
		"dev-perl/libwww-perl" \
		"dev-perl/TermReadKey"
	showpkgdeps git-quiltimport "dev-util/quilt"
	showpkgdeps git-cvsserver "dev-perl/DBI" "dev-perl/DBD-SQLite"
	showpkgdeps git-instaweb \
		"|| ( www-servers/lighttpd www-servers/apache(SLOT=2) )"
	showpkgdeps git-send-email "USE=perl"
	showpkgdeps git-remote "USE=perl"
	echo
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
