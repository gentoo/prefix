# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/db/db-5.1.19-r2.ebuild,v 1.1 2010/10/18 17:40:52 robbat2 Exp $

EAPI=2
inherit eutils db flag-o-matic java-pkg-opt-2 autotools libtool

#Number of official patches
#PATCHNO=`echo ${PV}|sed -e "s,\(.*_p\)\([0-9]*\),\2,"`
PATCHNO=${PV/*.*.*_p}
if [[ ${PATCHNO} == "${PV}" ]] ; then
	MY_PV=${PV}
	MY_P=${P}
	PATCHNO=0
else
	MY_PV=${PV/_p${PATCHNO}}
	MY_P=${PN}-${MY_PV}
fi

S_BASE="${WORKDIR}/${MY_P}"
S="${S_BASE}/build_unix"
DESCRIPTION="Oracle Berkeley DB"
HOMEPAGE="http://www.oracle.com/technology/software/products/berkeley-db/index.html"
SRC_URI="http://download.oracle.com/berkeley-db/${MY_P}.tar.gz"
for (( i=1 ; i<=${PATCHNO} ; i++ )) ; do
	export SRC_URI="${SRC_URI} http://www.oracle.com/technology/products/berkeley-db/db/update/${MY_PV}/patch.${MY_PV}.${i}"
done

LICENSE="OracleDB"
SLOT="5.1"
KEYWORDS="~ppc-aix ~x64-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc java nocxx tcl test"

# the entire testsuite needs the TCL functionality
DEPEND="tcl? ( >=dev-lang/tcl-8.4 )
	test? ( >=dev-lang/tcl-8.4 )
	java? ( >=virtual/jdk-1.5 )
	|| ( sys-devel/binutils-apple
		 sys-devel/native-cctools
		 >=sys-devel/binutils-2.16.1
	)"
RDEPEND="tcl? ( dev-lang/tcl )
	java? ( >=virtual/jre-1.5 )"

src_unpack() {
	unpack "${MY_P}".tar.gz
}

src_prepare() {
	cd "${WORKDIR}"/"${MY_P}"
	for (( i=1 ; i<=${PATCHNO} ; i++ ))
	do
		epatch "${DISTDIR}"/patch."${MY_PV}"."${i}"
	done
	epatch "${FILESDIR}"/${PN}-4.8-libtool.patch
	epatch "${FILESDIR}"/${PN}-4.8.24-java-manifest-location.patch

	epatch "${FILESDIR}"/${PN}-4.6-interix.patch

	pushd dist > /dev/null || die "Cannot cd to 'dist'"

	# need to upgrade local copy of libtool.m4
	# for correct shared libs on aix (#213277).
	local g="" ; type -P glibtoolize > /dev/null && g=g
	local _ltpath="$(dirname "$(dirname "$(type -P ${g}libtoolize)")")"
	cp -f "${_ltpath}"/share/aclocal/libtool.m4 aclocal/libtool.m4 \
		|| die "cannot update libtool.ac from libtool.m4"

	# need to upgrade ltmain.sh for AIX,
	# but aclocal.m4 is created in ./s_config,
	# and elibtoolize does not work when there is no aclocal.m4, so:
	${g}libtoolize --force --copy || die "${g}libtoolize failed."
	# now let shipped script do the autoconf stuff, it really knows best.
	#see code below
	#sh ./s_config || die "Cannot execute ./s_config"

	# use the includes from the prefix
	epatch "${FILESDIR}"/${PN}-4.6-jni-check-prefix-first.patch
	epatch "${FILESDIR}"/${PN}-4.3-listen-to-java-options.patch

	popd > /dev/null

	# upstream autoconf fails to build DBM when it's supposed to
	# merged upstream in 5.0.26
	#epatch "${FILESDIR}"/${PN}-5.0.21-enable-dbm-autoconf.patch

	# Upstream release script grabs the dates when the script was run, so lets
	# end-run them to keep the date the same.
	export REAL_DB_RELEASE_DATE="$(awk \
		'/^DB_VERSION_STRING=/{ gsub(".*\\(|\\).*","",$0); print $0; }' \
		"${S_BASE}"/dist/configure)"
	sed -r -i \
		-e "/^DB_RELEASE_DATE=/s~=.*~='${REAL_DB_RELEASE_DATE}'~g" \
		"${S_BASE}"/dist/RELEASE

	# Include the SLOT for Java JAR files
	# This supersedes the unused jarlocation patches.
	sed -r -i \
		-e '/jarfile=.*\.jar$/s,(.jar$),-$(LIBVERSION)\1,g' \
		"${S_BASE}"/dist/Makefile.in

	cd "${S_BASE}"/dist
	rm -f aclocal/libtool.m4
	sed -i \
		-e '/AC_PROG_LIBTOOL$/aLT_OUTPUT' \
		configure.ac
	sed -i \
		-e '/^AC_PATH_TOOL/s/ sh, none/ bash, none/' \
		aclocal/programs.m4
	AT_M4DIR="aclocal aclocal_java" eautoreconf
	# Upstream sucks - they do autoconf and THEN replace the version variables.
	. ./RELEASE
	for v in \
		DB_VERSION_{FAMILY,LETTER,RELEASE,MAJOR,MINOR} \
		DB_VERSION_{PATCH,FULL,UNIQUE_NAME,STRING,FULL_STRING} \
		DB_VERSION \
		DB_RELEASE_DATE ; do
		local ev="__EDIT_${v}__"
		sed -i -e "s/${ev}/${!v}/g" configure
	done
}

src_configure() {
	local myconf=''

	# compilation with -O0 fails on amd64, see bug #171231
	if use amd64; then
		replace-flags -O0 -O2
		is-flagq -O[s123] || append-flags -O2
	fi

	# use `set` here since the java opts will contain whitespace
	set --
	if use java ; then
		set -- "$@" \
			--with-java-prefix="${JAVA_HOME}" \
			--with-javac-flags="$(java-pkg_javac-args)"
	fi

	# Add linker versions to the symbols. Easier to do, and safer than header file
	# mumbo jumbo.
	if [[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* ]] ; then
		# we hopefully use a GNU binutils linker in this case
		append-ldflags -Wl,--default-symver
	fi

	tc-export CC CXX # would use CC=xlc_r on aix if not set

	# Bug #270851: test needs TCL support
	if use tcl || use test ; then
		myconf="${myconf} --enable-tcl"
		myconf="${myconf} --with-tcl=${EPREFIX}/usr/$(get_libdir)"
	else
		myconf="${myconf} --disable-tcl"
	fi

	# sql_compat will cause a collision with sqlite3
	# --enable-sql_compat
	cd "${S}"
	ECONF_SOURCE="${S_BASE}"/dist \
	STRIP="true" \
	econf \
		--enable-compat185 \
		--enable-dbm \
		--enable-o_direct \
		--without-uniquename \
		--enable-sql \
		--enable-sql_codegen \
		--disable-sql_compat \
		$(use arm && echo --with-mutex=ARM/gcc-assembly) \
		$(use amd64 && echo --with-mutex=x86/gcc-assembly) \
		$(use_enable !nocxx cxx) \
		$(use_enable !nocxx stl) \
		$(use_enable java) \
		${myconf} \
		$(use_enable test) \
		"$@"
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	emake install DESTDIR="${D}" || die

	db_src_install_usrbinslot

	db_src_install_headerslot

	db_src_install_doc

	db_src_install_usrlibcleanup

	dodir /usr/sbin
	# This file is not always built, and no longer exists as of db-4.8
	[[ -f "${ED}"/usr/bin/berkeley_db_svc ]] && \
	mv "${ED}"/usr/bin/berkeley_db_svc "${ED}"/usr/sbin/berkeley_db"${SLOT/./}"_svc

	if use java; then
		local ext=so
		[[ ${CHOST} == *-darwin* ]] && ext=jnilib #313085
		java-pkg_regso "${ED}"/usr/"$(get_libdir)"/libdb_java*.${ext}
		java-pkg_dojar "${ED}"/usr/"$(get_libdir)"/*.jar
		rm -f "${ED}"/usr/"$(get_libdir)"/*.jar
	fi
}

pkg_postinst() {
	db_fix_so
}

pkg_postrm() {
	db_fix_so
}

src_test() {
	# db_repsite is impossible to build, as upstream strips those sources.
	# db_repsite is used directly in the setup_site_prog,
	# setup_site_prog is called from open_site_prog
	# which is called only from tests in the multi_repmgr group.
	#sed -ri \
	#	-e '/set subs/s,multi_repmgr,,g' \
	#	"${S_BASE}/test/testparams.tcl"
	sed -ri \
		-e '/multi_repmgr/d' \
		"${S_BASE}/test/tcl/test.tcl"

	db_src_test
}
