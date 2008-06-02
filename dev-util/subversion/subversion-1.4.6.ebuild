# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/subversion/subversion-1.4.6.ebuild,v 1.13 2008/06/01 10:16:08 hollow Exp $

EAPI="prefix"

inherit bash-completion depend.apache flag-o-matic elisp-common eutils java-pkg-opt-2 multilib perl-module python autotools

KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="A compelling replacement for CVS."
HOMEPAGE="http://subversion.tigris.org/"
SRC_URI="http://subversion.tigris.org/downloads/${P/_rc/-rc}.tar.bz2"

LICENSE="Subversion"
SLOT="0"
IUSE="apache2 berkdb debug doc emacs extras java nls nowebdav perl python ruby svnserve vim-syntax"
RESTRICT="test"

COMMONDEPEND=">=dev-libs/apr-util-1.2.8
			berkdb? ( =sys-libs/db-4* )
			emacs? ( virtual/emacs )
			nls? ( sys-devel/gettext )
			!nowebdav? ( =net-misc/neon-0.26* )
			ruby? ( >=dev-lang/ruby-1.8.2 )
			perl? ( >=dev-lang/perl-5.8.8 )
			python? ( >=dev-lang/python-2.0 )"

RDEPEND="${COMMONDEPEND}
		java? ( >=virtual/jre-1.4 )
		perl? ( dev-perl/URI )"

DEPEND="${COMMONDEPEND}
		>=sys-devel/autoconf-2.59
		doc? ( app-doc/doxygen )
		java? ( >=virtual/jdk-1.4 )
		ruby? ( dev-lang/swig )
		perl? ( dev-lang/swig )
		python? ( dev-lang/swig )"

want_apache

S="${WORKDIR}"/${P/_rc/-rc}

# Allow for custom repository locations.
# This can't be in pkg_setup because the variable needs to be available to
# pkg_config.
: ${SVN_REPOS_LOC:=${EPREFIX}/var/svn}

pkg_setup() {
	if use berkdb ; then
		if ! built_with_use 'dev-libs/apr-util' berkdb ; then
			eerror "dev-libs/apr-util is missing USE=berkdb"
			die "dev-libs/apr-util is missing USE=berkdb"
		fi

		if has_version '<dev-util/subversion-0.34.0' && [[ -z ${SVN_DUMPED} ]] ; then
			echo
			ewarn "Presently you have $(best_version dev-util/subversion) installed."
			ewarn "Subversion has changed the repository filesystem schema from 0.34.0."
			ewarn "So you MUST dump your repositories before upgrading."
			ewarn
			ewarn 'After doing so call emerge with SVN_DUMPED=1 emerge !*'
			ewarn
			ewarn "More details on dumping:"
			ewarn "http://svn.collab.net/repos/svn/trunk/notes/repos_upgrade_HOWTO"
			echo
			die "Ensure that you dump your repository first"
		fi
	fi

	java-pkg-opt-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# assure we don't use the included libs by accident
	rm -Rf neon apr apr-util

	epatch "${FILESDIR}"/subversion-1.4-db4.patch
	epatch "${FILESDIR}"/subversion-1.1.1-perl-vendor.patch
	epatch "${FILESDIR}"/subversion-hotbackup-config.patch
	epatch "${FILESDIR}"/subversion-1.3.1-neon-config.patch
	epatch "${FILESDIR}"/subversion-apr_cppflags.patch
	epatch "${FILESDIR}"/subversion-1.4.3-debug-config.patch
	epatch "${FILESDIR}"/subversion-prefix.patch
	epatch "${FILESDIR}"/${PN}-1.4.2-interix-prompt.patch
	epatch "${FILESDIR}"/${P}-neon-version-quotes.patch
	eprefixify contrib/client-side/svn_load_dirs.pl.in

	sed -e 's/\(NEON_ALLOWED_LIST=.* 0.26.2\)"/\1 0.26.3 0.26.4"/' \
		-i configure.in

	sed -e "s:apr-config:apr-1-config:g" \
		-e "s:apu-config:apu-1-config:g" \
		-i build/ac-macros/{find_,}ap*


	export WANT_AUTOCONF=2.5

	# must copy to use our libtool, since it's hard-wired. also
	# aclocal.m4 is hand written, so no chance to handle it by
	# playing around with aclocal include paths.
	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 build/libtool.m4
	AT_M4DIR="build/ac-macros" eautoreconf

	sed -i -e 's,\(subversion/svnversion/svnversion.*\)\(>.*svn-revision.txt\),echo "exported" \2,' Makefile.in

	use emacs && cp "${FILESDIR}"/vc-svn.el "${S}"/contrib/client-side/vc-svn.el
}

src_compile() {
	local myconf=

	myconf="${myconf} $(use_enable java javahl)"
	use java && myconf="${myconf} --without-jikes --with-jdk=${JAVA_HOME}"

	if use python || use perl || use ruby ; then
		myconf="${myconf} --with-swig"
	else
		myconf="${myconf} --without-swig"
	fi

	if use nowebdav ; then
		myconf="${myconf} --without-neon"
	else
		myconf="${myconf} --with-neon=${EPREFIX}/usr"
	fi

	case ${CHOST} in
		*-darwin7)
			# KeyChain support on OSX Panther is broken, due to some library
			# includes which don't exist
			myconf="${myconf} --disable-keychain"
		;;
		*-*-solaris*)
			# -lintl isn't added for some reason
			use nls && append-ldflags -lintl
		;;
		*-aix*)
			# avoid recording immediate path to sharedlibs into executables
			append-ldflags -Wl,-bnoipath
		;;
	esac

	append-flags $("${EPREFIX}"/usr/bin/apr-1-config --cppflags)

	econf ${myconf} \
		--with-apr="${EPREFIX}"/usr/bin/apr-1-config \
		--with-apr-util="${EPREFIX}"/usr/bin/apu-1-config \
		$(use_with apache2 apxs ${APXS}) \
		$(use_with berkdb berkeley-db) \
		$(use_enable debug maintainer-mode) \
		$(use_enable nls) \
		--disable-experimental-libtool \
		--disable-mod-activation \
		|| die "econf failed"

	# Respect the user LDFLAGS
	export SWIG_LDFLAGS="${LDFLAGS}"

	# Build subversion, but do it in a way that is safe for parallel builds.
	# Also apparently the included apr has a libtool that doesn't like -L flags.
	# So not specifying it at all when not building apache modules and only
	# specify it for internal parts otherwise.
	( emake external-all && emake LT_LDFLAGS="-L${ED}/usr/$(get_libdir)" local-all ) || die "Compilation of ${PN} failed"

	if use python ; then
		# Building fails without the apache apr-util as includes are wrong.
		emake swig-py || die "Compilation of ${PN} Python bindings failed"
	fi

	if use perl ; then
		# Work around a buggy Makefile.PL, bug 64634
		mkdir -p subversion/bindings/swig/perl/native/blib/arch/auto/SVN/{_Client,_Delta,_Fs,_Ra,_Repos,_Wc}
		emake -j1 swig-pl || die "Compilation of ${PN} Perl bindings failed"
	fi

	if use ruby ; then
		emake swig-rb || die "Compilation of ${PN} Ruby bindings failed"
	fi

	if use java ; then
		# ensure that the destination dir exists, else some compilation fails
		mkdir -p "${S}"/subversion/bindings/java/javahl/classes
		# Compile javahl
		make JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl || die "make javahl failed"
	fi

	if use emacs ; then
		einfo "Compiling emacs support"
		elisp-compile "${S}"/contrib/client-side/psvn/psvn.el || die "emacs modules failed"
		elisp-compile "${S}"/contrib/client-side/vc-svn.el || die "emacs modules failed"
		elisp-compile "${S}"/doc/svn-doc.el || die "emacs modules failed"
		elisp-compile "${S}"/doc/tools/svnbook.el || die "emacs modules failed"
	fi

	if use doc ; then
		doxygen doc/doxygen.conf || die "doxygen failed"
	fi
}


src_install () {
	python_version
	PYTHON_DIR=/usr/$(get_libdir)/python${PYVER}

	make DESTDIR="${D}" install || die "Installation of ${PN} failed"

	if use python ; then
		make DESTDIR="${D}" DISTUTIL_PARAM="--prefix=${ED}" LD_LIBRARY_PATH="-L${ED}/usr/$(get_libdir)" install-swig-py \
			|| die "Installation of ${PN} Python bindings failed"

		# move python bindings
		dodir "${PYTHON_DIR}/site-packages"
		mv "${ED}"/usr/$(get_libdir)/svn-python/svn "${ED}${PYTHON_DIR}/site-packages"
		mv "${ED}"/usr/$(get_libdir)/svn-python/libsvn "${ED}${PYTHON_DIR}/site-packages"
		rm -Rf "${ED}"/usr/$(get_libdir)/svn-python
	fi

	if use perl ; then
		make DESTDIR="${D}" install-swig-pl || die "Installation of ${PN} Perl bindings failed"
		fixlocalpod
	fi

	if use ruby ; then
		make DESTDIR="${D}" install-swig-rb || die "Installation of ${PN} Ruby bindings failed"
	fi

	if use java ; then
		make DESTDIR="${D}" install-javahl || die "make install-javahl failed"
		java-pkg_regso "${ED}"/usr/$(get_libdir)/libsvnjavahl*$(get_libname)
		java-pkg_dojar "${ED}"/usr/$(get_libdir)/svn-javahl/svn-javahl.jar
		rm -Rf "${ED}"/usr/$(get_libdir)/svn-javahl/*.jar
	fi

	# Install apache2 module config
	if use apache2 ; then
		MOD="${APACHE_MODULESDIR/${APACHE_BASEDIR}\//}"
		dodir "${APACHE_MODULES_CONFDIR}"
		cat <<EOF >"${ED}/${APACHE_MODULES_CONFDIR}"/47_mod_dav_svn.conf
<IfDefine SVN>
	<IfModule !mod_dav_svn.c>
		LoadModule dav_svn_module	${MOD}/mod_dav_svn.so
	</IfModule>
	<IfDefine SVN_AUTHZ>
		<IfModule !mod_authz_svn.c>
			LoadModule authz_svn_module	${MOD}/mod_authz_svn.so
		</IfModule>
	</IfDefine>

	# example configuration:
	#<Location /svn/repos>
	#	DAV svn
	#	SVNPath ${SVN_REPOS_LOC}/repos
	#	AuthType Basic
	#	AuthName "Subversion repository"
	#	AuthUserFile ${SVN_REPOS_LOC}/conf/svnusers
	#	Require valid-user
	#</Location>
</IfDefine>
EOF
	fi

	# Bug 43179 - Install bash-completion if user wishes
	dobashcompletion tools/client-side/bash_completion subversion
	rm -f tools/client-side/bash_completion

	# Install hot backup script, bug 54304
	newbin tools/backup/hot-backup.py svn-hot-backup
	rm -fr tools/backup

	# The svn_load_dirs script is installed by Debian and looks like a good
	# candidate for us to install as well
	if use perl ; then
		newbin contrib/client-side/svn_load_dirs.pl svn-load-dirs
	fi
	rm -f contrib/client-side/svn_load_dirs.pl

	# Install svnserve init-script and xinet.d snippet, bug 43245
	if use svnserve; then
		newinitd "${FILESDIR}"/svnserve.initd svnserve
		if use apache2 ; then
			newconfd "${FILESDIR}"/svnserve.confd svnserve
		else
			newconfd "${FILESDIR}"/svnserve.confd2 svnserve
		fi
		insinto /etc/xinetd.d
		newins "${FILESDIR}"/svnserve.xinetd svnserve
	fi

	# Install documentation
	dodoc BUGS CHANGES COMMITTERS HACKING INSTALL README TRANSLATING
	dodoc tools/xslt/svnindex.{css,xsl}
	rm -fr tools/xslt

	if use doc ; then
		dohtml doc/doxygen/html/*
		cp -R notes "${ED}usr/share/doc/${PF}"
		ecompressdir "/usr/share/doc/${PF}/notes"
	fi

	# Install Vim syntax files.
	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles/syntax
		doins contrib/client-side/svn.vim
	fi
	rm -f contrib/client-side/svn.vim

	# Install emacs lisps
	if use emacs ; then
		elisp-install ${PN} contrib/client-side/psvn/psvn.el*
		elisp-install ${PN}/compat contrib/client-side/vc-svn.el*
		elisp-install ${PN} doc/svn-doc.el*
		elisp-install ${PN} doc/tools/svnbook.el*
		touch "${ED}${SITELISP}/${PN}/compat/.nosearch"

		elisp-site-file-install "${FILESDIR}"/70svn-gentoo.el
	fi
	rm -fr contrib/client-side/psvn/
	rm -f contrib/client-side/vc-svn.el*

	# Install extra files
	if use extras ; then
		find contrib tools '(' -name "*.bat" -o -name "*.in" ')' -print0 | xargs -0 rm -f
		rm -fr tools/{dev,po}
		dodir "/usr/share/${PN}"
		cp -R contrib tools "${ED}usr/share/${PN}"
	fi
}

pkg_preinst() {
	# Compare versions of Berkeley DB.
	if use berkdb && [[ -f "${EROOT}usr/bin/svn" ]] ; then
		OLD_BDB_VERSION="$(scanelf -qn "${EROOT}usr/lib/libsvn_subr-1.so.0" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		NEW_BDB_VERSION="$(scanelf -qn "${ED}usr/lib/libsvn_subr-1.so.0" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		if [[ "${OLD_BDB_VERSION}" != "${NEW_BDB_VERSION}" ]] ; then
			CHANGED_BDB_VERSION=1
		fi
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use perl && perl-module_pkg_postinst

	elog "Subversion Server Notes"
	elog "-----------------------"
	elog
	elog "If you intend to run a server, a repository needs to be created using"
	elog "svnadmin (see man svnadmin) or the following command to create it in"
	elog "${SVN_REPOS_LOC}:"
	elog
	elog "    emerge --config =${CATEGORY}/${PF}"
	elog
	elog "Subversion has multiple server types, take your pick:"
	elog
	if use svnserve; then
		elog " - svnserve daemon: "
		elog "   1. edit /etc/conf.d/svnserve"
		elog "   2. start daemon: /etc/init.d/svnserve start"
		elog "   3. make persistent: rc-update add svnserve default"
		elog
		elog " - svnserve via xinetd:"
		elog "   1. edit /etc/xinetd.d/svnserve (remove disable line)"
		elog "   2. restart xinetd.d: /etc/init.d/xinetd restart"
		elog
	fi
	elog " - svn over ssh:"
	elog "   1. Fix the repository permissions:"
	elog "        groupadd svnusers"
	elog "        chown -R root:svnusers ${SVN_REPOS_LOC}/repos/"
	elog "        chmod -R g-w ${SVN_REPOS_LOC}/repos"
	elog "        chmod -R g+rw ${SVN_REPOS_LOC}/repos/db"
	elog "        chmod -R g+rw ${SVN_REPOS_LOC}/repos/locks"
	elog "   2. create an svnserve wrapper in /usr/local/bin to set the umask you"
	elog "      want, for example:"
	elog "         #!/bin/bash"
	elog "         . /etc/conf.d/svnserve"
	elog "         umask 002"
	elog "         exec /usr/bin/svnserve \${SVNSERVE_OPTS} \"\$@\""
	elog
	if use apache2; then
		elog " - http-based server:"
		elog "   1. edit /etc/conf.d/apache2 to include both \"-D DAV\" and \"-D SVN\""
		elog "   2. create an htpasswd file:"
		elog "      htpasswd2 -m -c ${SVN_REPOS_LOC}/conf/svnusers USERNAME"
		elog
	fi

	elog "If you intend to use svn-hot-backup, you can specify the number of"
	elog "backups to keep per repository by specifying an environment variable."
	elog "If you want to keep e.g. 2 backups, do the following:"
	elog "echo '# hot-backup: Keep that many repository backups around' > /etc/env.d/80subversion"
	elog "echo 'SVN_HOTBACKUP_NUM_BACKUPS=2' >> /etc/env.d/80subversion"
	elog

	if [[ -n "${CHANGED_BDB_VERSION}" ]]; then
		ewarn "You upgraded from an older version of Berkely DB and may experience"
		ewarn "problems with your repository. Run the following commands as root to fix it:"
		ewarn "    db4_recover -h ${SVN_REPOS_LOC}/repos"
		ewarn "    chown -Rf apache:apache ${SVN_REPOS_LOC}/repos"
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
	use perl && perl-module_pkg_postrm
}

pkg_config() {
	if [[ ! -x "${EROOT}usr/bin/svnadmin" ]] ; then
		die "You seem to only have built the Subversion client"
	fi

	einfo ">>> Initializing the database in ${EROOT}${SVN_REPOS_LOC} ..."
	if [[ -e "${EROOT}${SVN_REPOS_LOC}/repos" ]] ; then
		echo "A subversion repository already exists and I will not overwrite it."
		echo "Delete ${EROOT}${SVN_REPOS_LOC}/repos first if you're sure you want to have a clean version."
	else
		mkdir -p "${EROOT}${SVN_REPOS_LOC}/conf"

		einfo ">>> Populating repository directory ..."
		# create initial repository
		"${EROOT}usr/bin/svnadmin" create "${EROOT}${SVN_REPOS_LOC}/repos"

		einfo ">>> Setting repository permissions ..."
		if use svnserve; then
			SVNSERVE_USER="$(. ${EROOT}etc/conf.d/svnserve ; echo ${SVNSERVE_USER})"
			SVNSERVE_GROUP="$(. ${EROOT}etc/conf.d/svnserve ; echo ${SVNSERVE_GROUP})"
		fi
		if use apache2 ; then
			[[ -z "${SVNSERVE_USER}" ]] && SVNSERVE_USER="apache"
			[[ -z "${SVNSERVE_GROUP}" ]] && SVNSERVE_GROUP="apache"
		else
			[[ -z "${SVNSERVE_USER}" ]] && SVNSERVE_USER="svn"
			[[ -z "${SVNSERVE_GROUP}" ]] && SVNSERVE_GROUP="svnusers"
			enewgroup "${SVNSERVE_GROUP}"
			enewuser "${SVNSERVE_USER}" -1 -1 ${SVN_REPOS_LOC} "${SVNSERVE_GROUP}"
		fi
		chown -Rf "${SVNSERVE_USER}:${SVNSERVE_GROUP}" "${EROOT}${SVN_REPOS_LOC}/repos"
		chmod -Rf 755 "${EROOT}${SVN_REPOS_LOC}/repos"
	fi
}
