# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rpm/rpm-4.4.7-r3.ebuild,v 1.4 2007/12/09 04:50:43 vapier Exp $

EAPI="prefix"

inherit eutils autotools distutils gnuconfig toolchain-funcs flag-o-matic

DESCRIPTION="Red Hat Package Management Utils"
HOMEPAGE="http://www.rpm.org/"
SRC_URI="http://wraptastic.org/pub/rpm-4.4.x/${P}.tar.gz
	http://dev.gentoo.org/~sanchan/patches/rpm-4.4.7-patches-1.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="berkdb doc elibc_uclibc java lua minimal nls perl python sqlite threads debug"
GUID="37"

RDEPEND="berkdb? ( >sys-libs/db-4 )
	>=sys-libs/zlib-1.2.3-r1
	>=app-arch/bzip2-1.0.1
	>=dev-libs/popt-1.7
	>=app-crypt/gnupg-1.2
	elibc_glibc? ( dev-libs/elfutils )
	virtual/libintl
	>=dev-libs/beecrypt-4.1.2
	python? ( >=dev-lang/python-2.2 )
	perl? ( >=dev-lang/perl-5.8.8 )
	nls? ( sys-devel/gettext )
	sqlite? ( >=dev-db/sqlite-3.3.5 )
	net-misc/neon"
#	lua? ( dev-lang/lua )
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	doc? ( app-doc/doxygen )"

pkg_setup() {
	if use perl; then
		ewarn "Perl bindings are provided by perl module RPM2. Just run:"
		ewarn "emerge app-portage/g-cpan"
		ewarn "g-cpan -i RPM2"
		ewarn "or if you prefer:"
		ewarn "g-cpan -i RPM4"
	fi
	if ! (use berkdb || use sqlite) ; then
		ewarn "Haven't chosen any database format, either berkdb or sqlite"
		ewarn "have to be used!"
		die
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/rpm-4.4.6-with-sqlite.patch
	epatch "${FILESDIR}"/rpm-4.4.7-stupidness.patch
	epatch "${FILESDIR}"/rpm-4.4.6-autotools.patch
	epatch "${FILESDIR}"/rpm-4.4.6-buffer-overflow.patch
	epatch "${WORKDIR}"/${P}-openpkg.bugfix.patch
	epatch "${WORKDIR}"/${P}-openpkg.porting.patch
	epatch "${WORKDIR}"/${P}-openpkg.feature.patch
	epatch "${WORKDIR}"/${P}-libintl.patch
	epatch "${FILESDIR}"/rpm-4.0.4-sandbox.patch
	epatch "${WORKDIR}"/${P}-zdefs.patch
	epatch "${WORKDIR}"/${P}-zdefs-x_functions.patch
	epatch "${WORKDIR}"/${P}-uclibc-nolibio.patch
	epatch "${WORKDIR}"/${P}-uclibc-no__fxstat64.patch
	epatch "${WORKDIR}"/${P}-fix-exec_prefix.patch

	epatch "${WORKDIR}"/${P}-no_threads.patch
	epatch "${WORKDIR}"/${P}-no_threads2.patch
	epatch "${WORKDIR}"/${P}-with-threads.patch

	epatch "${WORKDIR}"/${P}-gentoo.patch
	epatch "${WORKDIR}"/${P}-fix-redhat.patch
	epatch "${FILESDIR}"/rpm-4.0.4-gentoo-uclibc.patch

	#epatch "${WORKDIR}"/${P}-external_db.patch
	#epatch "${WORKDIR}"/${P}-external_db2.patch
	#epatch "${WORKDIR}"/${P}-external_db3.patch

	epatch "${WORKDIR}"/${P}-no_lua.patch
	epatch "${FILESDIR}"/${P}-qa-implicit-function-to-pointer.patch
	epatch "${FILESDIR}"/${P}-qa-fix-undefined.patch

	cp autodeps/linux.req autodeps/linux-uclibc.req
	cp autodeps/linux.prov autodeps/linux-uclibc.prov

	# rpm uses AM_GNU_GETTEXT() but fails to actually
	# include any of the required gettext files
	# the gettext files exist only if gettext is installed (not on uClibc)
	if use nls ; then
		cp /usr/share/gettext/config.rpath . || die
	else
		epatch "${FILESDIR}"/${P}-config.rpath.patch
		sed -i -e '/AM_GNU_GETTEXT/d' configure.ac
		sed -i -e '/^SUBDIRS/s:po::' Makefile.am
	fi
	if use elibc_uclibc ; then
		sed -i 's:--enable-rpc:--disable-rpc:' db3/configure
		sed -i 's:rpmdb_svc rpmdb_stat:rpmdb_stat:' rpmdb/Makefile.am
	fi

	# the following are additional libraries that might be packaged with
	# the rpm sources. grep for "test -d" in configure.ac
	cp file/src/{file,patchlevel}.h tools/
	rm -rf beecrypt elfutils neon popt sqlite zlib intl file syck tools perl
	use lua || rm -rf lua

	sed -i -e "s:intl ::" Makefile.am
	sed -i -e "s:intl/Makefile ::" configure.ac
	use nls || sed -i -e "s:@INTLLIBS@::" lib/Makefile.am
	sed -i -e '/lua\/Makefile/d' configure.ac
	sed -i -e '/syck\/Makefile/d' -e '/syck\/lib\/Makefile/d' configure.ac
	sed -i -e '/tools\/Makefile/d' configure.ac
	sed -i -e '/^SUBDIRS/s:tools scripts:scripts:' Makefile.am

	gnuconfig_update
	AT_NO_RECURSIVE="yes" eautoreconf
	# TODO: make it work with external lua too
}

src_compile() {
	# Until strict aliasing is porperly fixed...
	filter-flags -fstrict-aliasing
	append-flags -fno-strict-aliasing
	use debug && append-flags -g2 -ggdb && filter-flags -fomit-frame-pointer

	# we use arch-gentoo-linux-{gnu,uclibc} tuple
	export CHOST="${CHOST//-pc-/-gentoo-}"
	export CHOST="${CHOST//-unknown-/-gentoo-}"

	local myconf
	if use threads ; then
		myconf="--with-threads --enable-posixmutexes"
	else
		#myconf="--without-threads --disable-posixmutexes --with-mutex=\"UNIX/fcntl\""
		myconf="--without-threads --disable-posixmutexes"
	fi
	if use berkdb ; then
		myconf="${myconf} --with-db"
	else
		myconf="${myconf} --without-db"
	fi
	if use minimal ; then
		# it does not work with berkdb, hash method is missing
		if use berkdb ; then
			myconf="${myconf} --disable-cryptography --disable-queue --disable-replication --disable-verify"
		else
			myconf="${myconf} --enable-smallbuild"
		fi
	fi

	python_version
	econf ${myconf} \
		--without-javaglue \
		--without-selinux \
		--without-syck \
		--without-perl \
		$(use_with lua) \
		$(use_with python python ${PYVER}) \
		$(use_with doc apidocs) \
		$(use_with sqlite) \
		$(use_enable nls) \
		|| die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	mv "${ED}"/bin/rpm "${ED}"/usr/bin
	rmdir "${ED}"/bin

	use nls || rm -rf "${ED}"/usr/share/man/??

	keepdir /etc/rpm
	keepdir /var/spool/repackage
	keepdir /var/lib/rpm
	local dbi
	for dbi in \
			Basenames Conflictname Dirnames Group Installtid Name Packages \
			Providename Provideversion Requirename Requireversion Triggername \
			Filemd5s Pubkeys Sha1header Sigmd5 Depends \
			__db.001 __db.002 __db.003 __db.004 __db.006 __db.007 \
			__db.008 __db.009
	do
		touch "${ED}"/var/lib/rpm/${dbi}
	done
	keepdir /usr/src/gentoo/{SRPMS,SPECS,SOURCES,RPMS,BUILD}
	keepdir /usr/src/gentoo/RPMS/noarch
	keepdir /usr/src/gentoo/RPMS/$(tc-arch)
	local x
	if [[ $(tc-arch) == "x86" ]] ; then
		for x in athlon i386 i486 i586 i686 pentium3 pentium4 ; do
			keepdir /usr/src/gentoo/RPMS/${x}
		done
	#else
		#[[ $(tc-arch) == "ppc64" ]] && keepdir /usr/src/gentoo/RPMS/ppc
	fi

	dodoc CHANGES CREDITS GROUPS README* RPM*
	use doc && dohtml -r apidocs/html/*

	# remove development stuff
	rm -rf "${ED}"/usr/include
	rm -f "${ED}"/usr/lib/lib*.*a
	rm -f "${ED}"/usr/lib/rpm/rpmcache
	rm -f "${ED}"/usr/bin/rpmgraph
	rm -f "${ED}"/usr/share/man/man*/rpmcache*
	rm -f "${ED}"/usr/share/man/man*/rpmgraph*
	# remove unneeded links
	rm -f "${ED}"/usr/bin/rpm?
	# remove unused utilities/files
	#rm -f "${ED}"/usr/lib/rpm/rpm.{daily,log,xinetd}
	rm -f "${ED}"/usr/lib/rpm/rpm.xinetd
	[[ $(tc-arch) != "sparc64" ]] && rm -f "${ED}"/usr/lib/rpm/*sparc64*
	use java || rm -f "${ED}"/usr/lib/rpm/*java*
	dodir /etc/logrotate.d
	mv "${ED}"/usr/lib/rpm/rpm.log "${ED}"/etc/logrotate.d/rpm
	dodir /etc/cron.daily
	mv "${ED}"/usr/lib/rpm/rpm.daily "${ED}"/etc/cron.daily/rpm
	# remove unused requirement checks
	rm -f "${ED}"/usr/lib/rpm/{tcl,sql}.*
	# misc
	rm -f "${ED}"/usr/lib/rpm/{Specfile.pm,cpanflute,cpanflute2,rpmdiff,rpmdiff.cgi}
	# disable automatic perl requirements
	# puts too much info into db
	chmod 644 "${ED}"/usr/lib/rpm/perl.req

	for magic_file in "magic.mime.mgc" "magic.mgc" "magic.mime" "magic"; do
		dosym /usr/share/misc/file/${magic_file} /usr/lib/rpm/${magic_file}
	done

	dodir /etc/env.d
	echo 'CONFIG_PROTECT_MASK="/var/lib/rpm"' > "${ED}"/etc/env.d/50rpm
}

pkg_preinst() {
	enewgroup ${PN} ${GUID}
	enewuser ${PN} ${GUID} /bin/bash /var/lib/rpm rpm
}

pkg_postinst() {
	chown -R rpm:rpm ${EROOT}/usr/lib/rpm
	chown -R rpm:rpm ${EROOT}/var/lib/rpm
	chown rpm:rpm ${EROOT}/usr/bin/rpm{,2cpio,build,db,query,sign,verify}
	if [[ -f ${EROOT}/var/lib/rpm/Packages ]] ; then
		einfo "RPM database found... Rebuilding database (may take a while)..."
		"${EROOT}"/usr/bin/rpm --rebuilddb --root=${ROOT}
	else
		einfo "No RPM database found... Creating database..."
		"${EROOT}"/usr/bin/rpm --initdb --root=${ROOT}
	fi
	chown rpm:rpm ${EROOT}/var/lib/rpm/*

	distutils_pkg_postinst
}
