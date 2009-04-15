# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/subversion/subversion-1.6.0-r1.ebuild,v 1.8 2009/04/12 11:18:19 klausman Exp $

EAPI=1

WANT_AUTOMAKE="none"

inherit bash-completion db-use depend.apache elisp-common eutils flag-o-matic java-pkg-opt-2 libtool multilib perl-module python

DESCRIPTION="Advanced version control system"
HOMEPAGE="http://subversion.tigris.org/"
SRC_URI="http://subversion.tigris.org/downloads/${P/_/-}.tar.bz2"

LICENSE="Subversion"
SLOT="0"
KEYWORDS="~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="apache2 berkdb ctypes-python debug doc +dso emacs extras gnome-keyring java kde nls perl python ruby sasl vim-syntax +webdav-neon webdav-serf"
RESTRICT="test"

CDEPEND=">=dev-db/sqlite-3.4
	>=dev-libs/apr-1.3:1
	>=dev-libs/apr-util-1.3:1
	dev-libs/expat
	sys-libs/zlib
	berkdb? ( =sys-libs/db-4* )
	emacs? ( virtual/emacs )
	gnome-keyring? ( dev-libs/glib:2 sys-apps/dbus gnome-base/gnome-keyring )
	kde? ( sys-apps/dbus x11-libs/qt-core x11-libs/qt-dbus x11-libs/qt-gui >=kde-base/kdelibs-4 )
	ruby? ( >=dev-lang/ruby-1.8.2 )
	sasl? ( dev-libs/cyrus-sasl )
	webdav-neon? ( >=net-misc/neon-0.28 )
	webdav-serf? ( >=net-libs/serf-0.3.0 )"

RDEPEND="${CDEPEND}
	java? ( >=virtual/jre-1.5 )
	kde? ( kde-base/kwalletd )
	nls? ( virtual/libintl )
	perl? ( dev-perl/URI )"

DEPEND="${CDEPEND}
	ctypes-python? ( dev-python/ctypesgen )
	doc? ( app-doc/doxygen )
	gnome-keyring? ( dev-util/pkgconfig )
	java? ( >=virtual/jdk-1.5 )
	kde? ( dev-util/pkgconfig )
	nls? ( sys-devel/gettext )
	webdav-neon? ( dev-util/pkgconfig )"

want_apache

S="${WORKDIR}/${P/_/-}"

# Allow for custom repository locations.
# This can't be in pkg_setup() because the variable needs to be available to pkg_config().
: ${SVN_REPOS_LOC:=${EPREFIX}/var/svn}

pkg_setup() {
	if use kde && ! use nls; then
		eerror "Support for KWallet (KDE) requires Native Language Support (NLS)."
		die "Enable \"nls\" USE flag"
	fi

	if use berkdb; then
		einfo
		if [[ -z "${SVN_BDB_VERSION}" ]]; then
			SVN_BDB_VERSION="$(db_ver_to_slot "$(db_findver sys-libs/db 2>/dev/null)")"
			einfo "SVN_BDB_VERSION variable isn't set. You can set it to enforce using of specific version of Berkeley DB."
		fi
		einfo "Using: Berkeley DB ${SVN_BDB_VERSION}"
		einfo

		local apu_bdb_version="$(scanelf -nq "${EROOT}usr/$(get_libdir)/libaprutil-1.so.0" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		if [[ -n "${apu_bdb_version}" && "${SVN_BDB_VERSION}" != "${apu_bdb_version}" ]]; then
			eerror "APR-Util is linked against Berkeley DB ${apu_bdb_version}, but you are trying"
			eerror "to build Subversion with support for Berkeley DB ${SVN_BDB_VERSION}."
			eerror "Rebuild dev-libs/apr-util or set SVN_BDB_VERSION=\"${apu_bdb_version}\"."
			eerror "Aborting to avoid possible run-time crashes."
			die "Berkeley DB version mismatch"
		fi
	fi

	java-pkg-opt-2_pkg_setup

	if ! use webdav-neon && ! use webdav-serf; then
		ewarn
		ewarn "WebDAV support is disabled. You need WebDAV to"
		ewarn "access repositories through the HTTP protocol."
		ewarn
		ewarn "WebDAV support needs one of the following USE flags enabled:"
		ewarn "  webdav-neon webdav-serf"
		ewarn
		ewarn "You can do this by enabling one of these flags in /etc/portage/package.use:"
		ewarn "    ${CATEGORY}/${PN} webdav-neon webdav-serf"
		ewarn
		ebeep
	fi

	append-flags -fno-strict-aliasing

	if use debug; then
		append-cppflags -DSVN_DEBUG -DAP_DEBUG
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-disable_linking_against_unneeded_libraries.patch"

	# Various fixes which will be included in 1.6.1.
	epatch "${FILESDIR}/${P}-various_fixes.patch"

	# Fix 2 messages in Polish translation. They will be fixed in 1.6.1.
	sed -e "7420d;8586d" -i subversion/po/pl.po

	epatch "${FILESDIR}"/${PN}-1.5.4-interix.patch

	# https://svn.collab.net/viewvc/svn?view=revision&revision=36742
	sed -e 's/$SVN_APRUTIL_INCLUDES $SVN_DB_INCLUDES/$SVN_DB_INCLUDES $SVN_APRUTIL_INCLUDES/' -i build/ac-macros/berkeley-db.m4

	sed -i \
		-e "s/\(BUILD_RULES=.*\) bdb-test\(.*\)/\1\2/g" \
		-e "s/\(BUILD_RULES=.*\) test\(.*\)/\1\2/g" configure.ac

	sed -e "s:@bindir@/svn-contrib:@libdir@/subversion/bin:" \
		-e "s:@bindir@/svn-tools:@libdir@/subversion/bin:" \
		-i Makefile.in

	./autogen.sh || die "autogen.sh failed"
	elibtoolize
}

src_compile() {
	local myconf

	if use python || use perl || use ruby; then
		myconf="${myconf} --with-swig"
	else
		myconf="${myconf} --without-swig"
	fi

	case ${CHOST} in
		*-darwin7)
			# KeyChain support on OSX Panther is broken, due to some library
			# includes which don't exist
			myconf="${myconf} --disable-keychain"
		;;
		*-solaris*)
			# -lintl isn't added for some reason
			use nls && append-libs -lintl
		;;
		*-mint*)
			# probably a broken configure check somewhere
			append-libs -lpthread
		;;
		*-aix*)
			# avoid recording immediate path to sharedlibs into executables
			append-ldflags -Wl,-bnoipath
		;;
	esac

	econf --libdir="${EPREFIX}/usr/$(get_libdir)" \
		${myconf} \
		$(use_with apache2 apxs "${APXS}") \
		$(use_with berkdb berkeley-db "db.h:${EPREFIX}/usr/include/db${SVN_BDB_VERSION}::db-${SVN_BDB_VERSION}") \
		$(use_with ctypes-python ctypesgen "${EPREFIX}"/usr) \
		$(use_enable dso runtime-module-search) \
		$(use_with gnome-keyring) \
		$(use_enable java javahl) \
		$(use_with java jdk "${JAVA_HOME}") \
		$(use_with kde kwallet) \
		$(use_enable nls) \
		$(use_with sasl) \
		$(use_with webdav-neon neon ${EPREFIX}/usr) \
		$(use_with webdav-serf serf ${EPREFIX}/usr) \
		--with-apr="${EPREFIX}"/usr/bin/apr-1-config \
		--with-apr-util="${EPREFIX}"/usr/bin/apu-1-config \
		--disable-experimental-libtool \
		--without-jikes \
		--without-junit \
		--disable-mod-activation \
		--disable-neon-version-check \
		--with-sqlite="${EPREFIX}"/usr

	einfo
	einfo "Building of core of Subversion"
	einfo
	emake local-all || die "Building of core of Subversion failed"

	if use ctypes-python; then
		einfo
		einfo "Building of Subversion Ctypes Python bindings"
		einfo
		emake ctypes-python || die "Building of Subversion Ctypes Python bindings failed"
	fi

	if use python; then
		einfo
		einfo "Building of Subversion SWIG Python bindings"
		einfo
		emake swig_pydir="$(python_get_sitedir)/libsvn" swig_pydir_extra="$(python_get_sitedir)/svn" swig-py \
			|| die "Building of Subversion SWIG Python bindings failed"
	fi

	if use perl; then
		einfo
		einfo "Building of Subversion SWIG Perl bindings"
		einfo
		emake -j1 swig-pl || die "Building of Subversion SWIG Perl bindings failed"
	fi

	if use ruby; then
		einfo
		einfo "Building of Subversion SWIG Ruby bindings"
		einfo
		emake swig-rb || die "Building of Subversion SWIG Ruby bindings failed"
	fi

	if use java; then
		einfo
		einfo "Building of Subversion JavaHL library"
		einfo
		make JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1" javahl \
			|| die "Building of Subversion JavaHL library failed"
	fi

	if use emacs; then
		einfo
		einfo "Compilation of Emacs support"
		einfo
		elisp-compile contrib/client-side/emacs/{dsvn,psvn,vc-svn}.el doc/svn-doc.el doc/tools/svnbook.el || die "Compilation of Emacs modules failed"
	fi

	if use extras; then
		einfo
		einfo "Building of contrib and tools"
		einfo
		emake contrib || die "Building of contrib failed"
		emake tools || die "Building of tools failed"
	fi

	if use doc; then
		einfo
		einfo "Building of Subversion HTML documentation"
		einfo
		doxygen doc/doxygen.conf || die "Building of Subversion HTML documentation failed"

		if use java; then
			einfo
			einfo "Building of Subversion JavaHL library HTML documentation"
			einfo
			emake doc-javahl || die "Building of Subversion JavaHL library HTML documentation failed"
		fi
	fi
}

src_install() {
	einfo
	einfo "Installation of core of Subversion"
	einfo
	emake -j1 DESTDIR="${D}" local-install || die "Installation of core of Subversion failed"

	if use ctypes-python; then
		einfo
		einfo "Installation of Subversion Ctypes Python bindings"
		einfo
		emake DESTDIR="${D}" install-ctypes-python || die "Installation of Subversion Ctypes Python bindings failed"
	fi

	if use python; then
		einfo
		einfo "Installation of Subversion SWIG Python bindings"
		einfo
		emake -j1 DESTDIR="${D}" swig_pydir="$(python_get_sitedir)/libsvn" swig_pydir_extra="$(python_get_sitedir)/svn" install-swig-py \
			|| die "Installation of Subversion SWIG Python bindings failed"
	fi

	if use perl; then
		einfo
		einfo "Installation of Subversion SWIG Perl bindings"
		einfo
		emake -j1 DESTDIR="${D}" INSTALLDIRS="vendor" install-swig-pl || die "Installation of Subversion SWIG Perl bindings failed"
		fixlocalpod
		find "${ED}" "(" -name .packlist -o -name "*.bs" ")" -print0 | xargs -0 rm -fr
	fi

	if use ruby; then
		einfo
		einfo "Installation of Subversion SWIG Ruby bindings"
		einfo
		emake -j1 DESTDIR="${D}" install-swig-rb || die "Installation of Subversion SWIG Ruby bindings failed"
	fi

	if use java; then
		einfo
		einfo "Installation of Subversion JavaHL library"
		einfo
		emake -j1 DESTDIR="${D}" install-javahl || die "Installation of Subversion JavaHL library failed"
		java-pkg_regso "${ED}"usr/$(get_libdir)/libsvnjavahl*$(get_libname)
		java-pkg_dojar "${ED}"usr/$(get_libdir)/svn-javahl/svn-javahl.jar
		rm -Rf "${ED}"usr/$(get_libdir)/svn-javahl/*.jar
	fi

	# Install Apache module configuration.
	if use apache2; then
		dodir "${APACHE_MODULES_CONFDIR#${EPREFIX}}"
		cat <<EOF >"${D}${APACHE_MODULES_CONFDIR}"/47_mod_dav_svn.conf
<IfDefine SVN>
LoadModule dav_svn_module modules/mod_dav_svn.so
<IfDefine SVN_AUTHZ>
LoadModule authz_svn_module modules/mod_authz_svn.so
</IfDefine>

# Example configuration:
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

	# Install Bash Completion, bug 43179.
	dobashcompletion tools/client-side/bash_completion subversion
	rm -f tools/client-side/bash_completion

	# Install hot backup script, bug 54304.
	newbin tools/backup/hot-backup.py svn-hot-backup
	rm -fr tools/backup

	# Install svn_load_dirs.pl.
	if use perl; then
		dobin contrib/client-side/svn_load_dirs/svn_load_dirs.pl
	fi
	rm -f contrib/client-side/svn_load_dirs/svn_load_dirs.pl

	# Install svnserve init-script and xinet.d snippet, bug 43245.
	newinitd "${FILESDIR}"/svnserve.initd svnserve
	if use apache2; then
		newconfd "${FILESDIR}"/svnserve.confd svnserve
	else
		newconfd "${FILESDIR}"/svnserve.confd2 svnserve
	fi
	insinto /etc/xinetd.d
	newins "${FILESDIR}"/svnserve.xinetd svnserve

	# Install documentation.
	dodoc CHANGES COMMITTERS README
	dohtml www/hacking.html
	dodoc tools/xslt/svnindex.{css,xsl}
	rm -fr tools/xslt

	# Install Vim syntax files.
	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins contrib/client-side/vim/svn.vim
	fi
	rm -f contrib/client-side/vim/svn.vim

	# Install Emacs Lisps.
	if use emacs; then
		elisp-install ${PN} contrib/client-side/emacs/{dsvn,psvn}.{el,elc} doc/svn-doc.{el,elc} doc/tools/svnbook.{el,elc} || die "Installation of Emacs modules failed"
		elisp-install ${PN}/compat contrib/client-side/emacs/vc-svn.{el,elc} || die "Installation of Emacs modules failed"
		touch "${ED}${SITELISP}/${PN}/compat/.nosearch"
		elisp-site-file-install "${FILESDIR}/1.5.0/70svn-gentoo.el" || die "Installation of Emacs site-init file failed"
	fi
	rm -fr contrib/client-side/emacs

	# Install extra files.
	if use extras; then
		einfo
		einfo "Installation of contrib and tools"
		einfo
		doenvd "${FILESDIR}/1.5.0/80subversion-extras"
		emake DESTDIR="${D}" install-contrib || die "Installation of contrib failed"
		emake DESTDIR="${D}" install-tools || die "Installation of tools failed"

		find contrib tools "(" -name "*.bat" -o -name "*.in" -o -name ".libs" ")" -print0 | xargs -0 rm -fr
		rm -fr contrib/client-side/svn-push
		rm -fr contrib/server-side/svnstsw
		rm -fr tools/client-side/svnmucc
		rm -fr tools/server-side/{svn-populate-node-origins-index,svnauthz-validate}*
		rm -fr tools/{buildbot,dev,diff,po}

		insinto /usr/share/${PN}
		doins -r contrib tools
	fi

	if use doc; then
		einfo
		einfo "Installation of Subversion HTML documentation"
		einfo
		dohtml doc/doxygen/html/* || die "Installation of Subversion HTML documentation failed"

		insinto /usr/share/doc/${PF}
		doins -r notes
		ecompressdir /usr/share/doc/${PF}/notes

#		if use ruby; then
#			make DESTDIR="${D}" install-swig-rb-doc
#		fi

		if use java; then
			java-pkg_dojavadoc doc/javadoc
		fi
	fi
}

pkg_preinst() {
	# Compare versions of Berkeley DB, bug 122877.
	if use berkdb && [[ -f "${EROOT}usr/bin/svn" ]]; then
		OLD_BDB_VERSION="$(scanelf -nq "${EROOT}usr/$(get_libdir)/libsvn_subr-1.so.0" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		NEW_BDB_VERSION="$(scanelf -nq "${ED}usr/$(get_libdir)/libsvn_subr-1.so.0" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		if [[ "${OLD_BDB_VERSION}" != "${NEW_BDB_VERSION}" ]]; then
			CHANGED_BDB_VERSION=1
		fi
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use perl && perl-module_pkg_postinst

	if use ctypes-python; then
		python_mod_compile "$(python_get_sitedir)/csvn/"{.,core,ext}/*.py
	fi

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
	elog " - svnserve daemon: "
	elog "   1. Edit /etc/conf.d/svnserve"
	elog "   2. Fix the repository permissions (see \"Fixing the repository permissions\")"
	elog "   3. Start daemon: /etc/init.d/svnserve start"
	elog "   4. Make persistent: rc-update add svnserve default"
	elog
	elog " - svnserve via xinetd:"
	elog "   1. Edit /etc/xinetd.d/svnserve (remove disable line)"
	elog "   2. Fix the repository permissions (see \"Fixing the repository permissions\")"
	elog "   3. Restart xinetd.d: /etc/init.d/xinetd restart"
	elog
	elog " - svn over ssh:"
	elog "   1. Fix the repository permissions (see \"Fixing the repository permissions\")"
	elog "      Additionally run:"
	elog "        groupadd svnusers"
	elog "        chown -R root:svnusers ${SVN_REPOS_LOC}/repos"
	elog "   2. Create an svnserve wrapper in /usr/local/bin to set the umask you"
	elog "      want, for example:"
	elog "         #!/bin/bash"
	elog "         . /etc/conf.d/svnserve"
	elog "         umask 007"
	elog "         exec /usr/bin/svnserve \${SVNSERVE_OPTS} \"\$@\""
	elog

	if use apache2; then
		elog " - http-based server:"
		elog "   1. Edit /etc/conf.d/apache2 to include both \"-D DAV\" and \"-D SVN\""
		elog "   2. Create an htpasswd file:"
		elog "      htpasswd2 -m -c ${SVN_REPOS_LOC}/conf/svnusers USERNAME"
		elog "   3. Fix the repository permissions (see \"Fixing the repository permissions\")"
		elog "   4. Restart Apache: /etc/init.d/apache2 restart"
		elog
	fi

	elog " Fixing the repository permissions:"
	elog "      chmod -Rf go-rwx ${SVN_REPOS_LOC}/conf"
	elog "      chmod -Rf g-w,o-rwx ${SVN_REPOS_LOC}/repos"
	elog "      chmod -Rf g+rw ${SVN_REPOS_LOC}/repos/db"
	elog "      chmod -Rf g+rw ${SVN_REPOS_LOC}/repos/locks"
	elog

	elog "If you intend to use svn-hot-backup, you can specify the number of"
	elog "backups to keep per repository by specifying an environment variable."
	elog "If you want to keep e.g. 2 backups, do the following:"
	elog "echo '# hot-backup: Keep that many repository backups around' > /etc/env.d/80subversion"
	elog "echo 'SVN_HOTBACKUP_BACKUPS_NUMBER=2' >> /etc/env.d/80subversion"
	elog

	elog "Subversion contains support for the use of Memcached"
	elog "to cache data of FSFS repositories."
	elog "You should install \"net-misc/memcached\", start memcached"
	elog "and configure your FSFS repositories, if you want to use this feature."
	elog "See the documentation for details."
	elog
	epause 6

	if [[ -n "${CHANGED_BDB_VERSION}" ]]; then
		ewarn "You upgraded from an older version of Berkeley DB and may experience"
		ewarn "problems with your repository. Run the following commands as root to fix it:"
		ewarn "    db4_recover -h ${SVN_REPOS_LOC}/repos"
		ewarn "    chown -Rf apache:apache ${SVN_REPOS_LOC}/repos"
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
	use perl && perl-module_pkg_postrm

	if use ctypes-python; then
		python_mod_cleanup
	fi
}

pkg_config() {
	if [[ ! -x "${EROOT}usr/bin/svnadmin" ]]; then
		die "You seem to only have built the Subversion client"
	fi

	einfo ">>> Initializing the database in ${EROOT}${SVN_REPOS_LOC} ..."
	if [[ -e "${EROOT}${SVN_REPOS_LOC}/repos" ]]; then
		echo "A Subversion repository already exists and I will not overwrite it."
		echo "Delete \"${EROOT}${SVN_REPOS_LOC}/repos\" first if you're sure you want to have a clean version."
	else
		mkdir -p "${EROOT}${SVN_REPOS_LOC}/conf"

		einfo ">>> Populating repository directory ..."
		# Create initial repository.
		"${EROOT}usr/bin/svnadmin" create "${EROOT}${SVN_REPOS_LOC}/repos"

		einfo ">>> Setting repository permissions ..."
		SVNSERVE_USER="$(. "${EROOT}etc/conf.d/svnserve"; echo "${SVNSERVE_USER}")"
		SVNSERVE_GROUP="$(. "${EROOT}etc/conf.d/svnserve"; echo "${SVNSERVE_GROUP}")"
		if use apache2; then
			[[ -z "${SVNSERVE_USER}" ]] && SVNSERVE_USER="apache"
			[[ -z "${SVNSERVE_GROUP}" ]] && SVNSERVE_GROUP="apache"
		else
			[[ -z "${SVNSERVE_USER}" ]] && SVNSERVE_USER="svn"
			[[ -z "${SVNSERVE_GROUP}" ]] && SVNSERVE_GROUP="svnusers"
			enewgroup "${SVNSERVE_GROUP}"
			enewuser "${SVNSERVE_USER}" -1 -1 "${SVN_REPOS_LOC}" "${SVNSERVE_GROUP}"
		fi
		chown -Rf "${SVNSERVE_USER}:${SVNSERVE_GROUP}" "${EROOT}${SVN_REPOS_LOC}/repos"
		chmod -Rf go-rwx "${EROOT}${SVN_REPOS_LOC}/conf"
		chmod -Rf o-rwx "${EROOT}${SVN_REPOS_LOC}/repos"
	fi
}
