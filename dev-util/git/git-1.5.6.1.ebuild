# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/git/git-1.5.6.1.ebuild,v 1.1 2008/06/26 21:42:43 robbat2 Exp $

EAPI="prefix"

inherit toolchain-funcs eutils elisp-common perl-module bash-completion multilib

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
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="curl cgi doc emacs gtk iconv mozsha1 perl ppcsha1 tk threads webdav xinetd cvs subversion vim-syntax"

DEPEND="
	!app-misc/git
	dev-libs/openssl
	sys-libs/zlib
	app-arch/cpio
	perl?   ( dev-lang/perl )
	tk?     ( dev-lang/tk )
	curl?   (
		net-misc/curl
		webdav? ( dev-libs/expat )
	)
	emacs?  ( virtual/emacs )"

RDEPEND="${DEPEND}
	perl? ( dev-perl/Error
			dev-perl/Net-SMTP-SSL
			dev-perl/Authen-SASL
			cgi? ( virtual/perl-CGI )
			cvs? ( >=dev-util/cvsps-2.1 dev-perl/DBI dev-perl/DBD-SQLite )
			subversion? ( dev-util/subversion dev-perl/libwww-perl dev-perl/TermReadKey )
			)
	gtk?  ( >=dev-python/pygtk-2.8 )"

SITEFILE=72${PN}-gentoo.el
S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if ! use perl ; then
		use cgi && ewarn "gitweb needs USE=perl, ignoring USE=cgi"
		use cvs && ewarn "CVS integration needs USE=perl, ignoring USE=cvs"
		use subversion && ewarn "git-svn needs USE=perl, it won't work"
	fi
	if use webdav && ! use curl ; then
		ewarn "USE=webdav needs USE=curl. Ignoring"
	fi
}

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
	fi

	# broken assumptions, because of broken build system ...
	myopts="${myopts} NO_FINK=YesPlease NO_DARWIN_PORTS=YesPlease"
	[[ ${CHOST} == *-solaris* ]] &&
		myopts="${myopts} INSTALL=install TAR=tar"
	use elibc_glibc || myopts="${myopts} NEEDS_LIBICONV=YesPlease ICONVDIR=${EPREFIX}/usr/$(get_libdir)"

	use iconv || myopts="${myopts} NO_ICONV=YesPlease"
	use tk || myopts="${myopts} NO_TCLTK=YesPlease"
	use perl || myopts="${myopts} NO_PERL=YesPlease"
	use threads && myopts="${myopts} THREADED_DELTA_SEARCH=YesPlease"
	use subversion || myopts="${myopts} NO_SVN_TESTS=YesPlease"

	if [[ ${CHOST} == *-interix* ]] ; then
		myopts="${myopts} NO_IPV6=YesPlease"
		myopts="${myopts} NO_MEMMEM=YesPlease"
		myopts="${myopts} NO_MKDTEMP=YesPlease"
		myopts="${myopts} NO_STRTOUMAX=YesPlease"
		myopts="${myopts} NO_STRTOULL=YesPlease"
		myopts="${myopts} NO_INET_NTOP=YesPlease"
		myopts="${myopts} NO_INET_PTON=YesPlease"
	fi

	export MY_MAKEOPTS="${myopts}"
}

src_unpack() {
	unpack ${MY_P}.tar.bz2
	cd "${S}"
	unpack ${PN}-manpages-${DOC_VER}.tar.bz2
	use doc && cd "${S}"/Documentation && unpack ${PN}-htmldocs-${DOC_VER}.tar.bz2
	cd "${S}"

	epatch "${FILESDIR}"/20080626-git-1.5.6.1-noperl.patch

	sed -i \
		-e "s:^\(CFLAGS =\).*$:\1 ${CFLAGS} -Wall:" \
		-e "s:^\(LDFLAGS =\).*$:\1 ${LDFLAGS}:" \
		-e "s:^\(CC = \).*$:\1$(tc-getCC):" \
		-e "s:^\(AR = \).*$:\1$(tc-getAR):" \
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
	if use perl && use cgi ; then
		emake ${MY_MAKEOPTS} \
		DESTDIR="${ED}" \
		prefix=/usr \
		gitweb/gitweb.cgi || die "make gitweb/gitweb.cgi failed"
	fi
}

src_install() {
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr install || die "make install failed"

	doman man?/*

	dodoc README Documentation/{SubmittingPatches,CodingGuidelines}
	use doc && dodir /usr/share/doc/${PF}/html
	for d in / /howto/ /technical/ ; do
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
	fi

	dobin contrib/fast-import/git-p4
	dodoc contrib/fast-import/git-p4.txt
	newbin contrib/fast-import/import-tars.perl import-tars

	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles/syntax/
		doins contrib/vim/syntax/gitcommit.vim
		insinto /usr/share/vim/vimfiles/ftdetect/
		newins "${FILESDIR}"/vim-ftdetect-gitcommit.vim gitcommit.vim
	fi

	dodir /usr/share/${PN}/contrib
	# The following are excluded:
	# svnimport - use git-svn
	# p4import - excluded because fast-import has a better one
	# examples - these are stuff that is not used in Git anymore actually
	# patches - stuff the Git guys made to go upstream to other places
	for i in continuous fast-import hg-to-git \
		hooks remotes2config.sh stats \
		workdir convert-objects blameview ; do
		cp -rf \
			"${S}"/contrib/${i} \
			"${ED}"/usr/share/${PN}/contrib \
			|| die "Failed contrib ${i}"
	done

	if use perl && use cgi ; then
		dodir /usr/share/${PN}/gitweb
		insinto /usr/share/${PN}/gitweb
		doins "${S}"/gitweb/gitweb.cgi
		doins "${S}"/gitweb/gitweb.css
		doins "${S}"/gitweb/git-{favicon,logo}.png

		# Make sure it can run
		fperms 0755 /usr/share/${PN}/gitweb/gitweb.cgi

		# INSTALL discusses configuration issues, not just installation
		docinto /
		newdoc  "${S}"/gitweb/INSTALL INSTALL.gitweb
		newdoc  "${S}"/gitweb/README README.gitweb
	fi

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}"/git-daemon.xinetd git-daemon
	fi

	newinitd "${FILESDIR}"/git-daemon.initd git-daemon
	newconfd "${FILESDIR}"/git-daemon.confd git-daemon

	fixlocalpod
}

src_test() {
	local disabled=""
	local tests_cvs="t9200-git-cvsexportcommit.sh \
					t9400-git-cvsserver-server.sh \
					t9600-cvsimport.sh"
	local tests_perl="t5502-quickfetch.sh \
					t5512-ls-remote.sh \
					t5520-pull.sh"

	# Unzip is used only for the testcase code, not by any normal parts of Git.
	has_version app-arch/unzip || \
		einfo "Disabling tar-tree tests" && \
		disabled="${disabled} \
					t5000-tar-tree.sh"

	if ! has userpriv "${FEATURES}"; then
		ewarn "Skipping CVS tests because CVS does not work as root!"
		ewarn "You should retest with FEATURES=userpriv!"
		disabled="${disabled} \
					${tests_cvs}"
	fi

	use cvs && \
		has_version dev-util/cvs && \
		built_with_use dev-util/cvs server || \
		einfo "Disabling CVS tests (needs dev-util/cvs[USE=server])" && \
		disabled="${disabled} \
					${tests_cvs}"

	use perl || \
		einfo "Disabling tests that need Perl" && \
		disabled="${disabled} \
					${tests_perl}"

	# Reset all previously disabled tests
	cd "${S}/t"
	for i in *.sh.DISABLED ; do
		[[ -f "${i}" ]] && mv -f "${i}" "${i%.DISABLED}"
	done
	einfo "Disabled tests:"
	for i in ${disabled} ; do
		[[ -f "${i}" ]] && mv -f "${i}" "${i}.DISABLED" && einfo "Disabled $i"
	done
	cd "${S}"
	# Now run the tests
	einfo "Start test run"
	emake ${MY_MAKEOPTS} DESTDIR="${D}" prefix="${EPREFIX}"/usr test || die "tests failed"
}

showpkgdeps() {
	local pkg=$1
	shift
	elog "  $(printf "%-17s:" ${pkg}) ${@}"
}

pkg_postinst() {
	if use emacs ; then
		elisp-site-regen
		elog "GNU Emacs has built-in Git support in versions greater 22.1."
		elog "You can disable the emacs USE flag for dev-util/git"
		elog "if you are using such a version."
	fi
	if use subversion && ! built_with_use dev-util/subversion perl ; then
		ewarn "You must build dev-util/subversion with USE=perl"
		ewarn "to get the full functionality of git-svn!"
	fi
	elog "These additional scripts need some dependencies:"
	echo
	showpkgdeps git-archimport "dev-util/tla"
	showpkgdeps git-quiltimport "dev-util/quilt"
	showpkgdeps git-instaweb \
		"|| ( www-servers/lighttpd www-servers/apache )"
	echo
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
