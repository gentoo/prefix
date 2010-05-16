# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/db/db-4.6.21_p4.ebuild,v 1.11 2010/05/03 23:21:52 robbat2 Exp $

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

S="${WORKDIR}/${MY_P}/build_unix"
DESCRIPTION="Oracle Berkeley DB"
HOMEPAGE="http://www.oracle.com/technology/software/products/berkeley-db/index.html"
SRC_URI="http://download.oracle.com/berkeley-db/${MY_P}.tar.gz"
for (( i=1 ; i<=${PATCHNO} ; i++ )) ; do
	export SRC_URI="${SRC_URI} http://www.oracle.com/technology/products/berkeley-db/db/update/${MY_PV}/patch.${MY_PV}.${i}"
done

LICENSE="OracleDB"
SLOT="4.6"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="tcl java doc nocxx"

DEPEND="tcl? ( >=dev-lang/tcl-8.4 )
	java? ( >=virtual/jdk-1.4 )
	|| ( sys-devel/binutils-apple
		 sys-devel/native-cctools
		 >=sys-devel/binutils-2.16.1
	)"
RDEPEND="tcl? ( dev-lang/tcl )
	java? ( >=virtual/jre-1.4 )
	x86-winnt? ( sys-libs/onc-rpc-nt )"

src_unpack() {
	unpack "${MY_P}".tar.gz
	cd "${WORKDIR}"/"${MY_P}"
	for (( i=1 ; i<=${PATCHNO} ; i++ ))
	do
		epatch "${DISTDIR}"/patch."${MY_PV}"."${i}"
	done

	epatch "${FILESDIR}"/${PN}-4.6-interix.patch

	cd dist || die "Cannot cd to 'dist'"

	# need to upgrade local copy of libtool.m4
	# for correct shared libs on aix (#213277).
	local mylibtoolize=libtoolize
	[[ ${CHOST} == *-darwin* ]] && mylibtoolize=glibtoolize
	local mylt=$(type -P ${mylibtoolize})
	cp -f "${mylt%/bin/${mylibtoolize}}"/share/aclocal/libtool.m4 aclocal/libtool.m4 \
	|| die "cannot update libtool.ac from libtool.m4"

	# need to upgrade ltmain.sh for AIX,
	# but aclocal.m4 is created in ./s_config,
	# and elibtoolize does not work when there is no aclocal.m4, so:
	if type -P glibtoolize > /dev/null ; then
		glibtoolize --force --copy || die "glibtoolize failed."
	else
		libtoolize --force --copy || die "libtoolize failed."
	fi
	# now let shipped script do the autoconf stuff, it really knows best.
	#see below
	#sh ./s_config || die "Cannot execute ./s_config"

	epatch "${FILESDIR}"/"${PN}"-"${SLOT}"-libtool.patch

	# use the includes from the prefix
	epatch "${FILESDIR}"/"${PN}"-"${SLOT}"-jni-check-prefix-first.patch
	epatch "${FILESDIR}"/"${PN}"-4.3-listen-to-java-options.patch

	cd "${WORKDIR}"/"${MY_P}"
	[[ ${CHOST} == *-winnt* ]] && epatch "${FILESDIR}"/${PN}-4.6-winnt.patch

	sed -e "/^DB_RELEASE_DATE=/s/%B %e, %Y/%Y-%m-%d/" -i dist/RELEASE

	# Include the SLOT for Java JAR files
	# This supersedes the unused jarlocation patches.
	sed -r -i \
		-e '/jarfile=.*\.jar$/s,(.jar$),-$(LIBVERSION)\1,g' \
		"${S}"/../dist/Makefile.in

	cd "${S}"/../dist
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
	sed -i \
		-e "s/__EDIT_DB_VERSION_MAJOR__/$DB_VERSION_MAJOR/g" \
		-e "s/__EDIT_DB_VERSION_MINOR__/$DB_VERSION_MINOR/g" \
		-e "s/__EDIT_DB_VERSION_PATCH__/$DB_VERSION_PATCH/g" \
		-e "s/__EDIT_DB_VERSION_STRING__/$DB_VERSION_STRING/g" \
		-e "s/__EDIT_DB_VERSION_UNIQUE_NAME__/$DB_VERSION_UNIQUE_NAME/g" \
		-e "s/__EDIT_DB_VERSION__/$DB_VERSION/g" configure
}

src_compile() {
	# compilation with -O0 fails on amd64, see bug #171231
	if use amd64; then
		replace-flags -O0 -O2
		is-flagq -O[s123] || append-flags -O2
	fi

	local myconf=""

	use amd64 && myconf="${myconf} --with-mutex=x86/gcc-assembly"

	myconf="${myconf} $(use_enable !nocxx cxx)"

	use tcl \
		&& myconf="${myconf} --enable-tcl --with-tcl=${EPREFIX}/usr/$(get_libdir)" \
		|| myconf="${myconf} --disable-tcl"

	myconf="${myconf} $(use_enable java)"
	if use java; then
		myconf="${myconf} --with-java-prefix=${JAVA_HOME}"
		# Can't get this working any other way, since it returns spaces, and
		# bash doesn't seem to want to pass correctly in any way i try
		local javaconf="-with-javac-flags=$(java-pkg_javac-args)"
	fi

	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"

	# the entire testsuite needs the TCL functionality
	if use tcl && use test ; then
		myconf="${myconf} --enable-test"
	else
		myconf="${myconf} --disable-test"
	fi

	# Add linker versions to the symbols. Easier to do, and safer than header file
	# mumbo jumbo.
	if [[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* ]] ; then
		# we hopefully use a GNU binutils linker in this case
		append-ldflags -Wl,--default-symver
	fi
	
	if [[ ${CHOST} == *-winnt* ]]; then
		# this one should really sound --enable-windows, but
		# seems the db devs only support mingw ... doesn't enable
		# anything too specific to mingw.
		myconf="${myconf} --enable-mingw"
		myconf="${myconf} --with-mutex=win32"
	fi

	cd "${S}" && ECONF_SOURCE="${S}"/../dist CC=$(tc-getCC) econf \
		--prefix="${EPREFIX}"/usr \
		--mandir="${EPREFIX}"/usr/share/man \
		--infodir="${EPREFIX}"/usr/share/info \
		--datadir="${EPREFIX}"/usr/share \
		--sysconfdir="${EPREFIX}"/etc \
		--localstatedir="${EPREFIX}"/var/lib \
		--libdir="${EPREFIX}"/usr/"$(get_libdir)" \
		--enable-compat185 \
		--enable-o_direct \
		--without-uniquename \
		--enable-rpc \
		--host="${CHOST}" \
		${myconf} "${javaconf}" || die "configure failed"

	sed -e "s,\(^STRIP *=\).*,\1\"true\"," Makefile > Makefile.cpy \
	    && mv Makefile.cpy Makefile

	emake || die "make failed"
}

src_install() {
	einstall libdir="${ED}/usr/$(get_libdir)" STRIP="true" || die

	db_src_install_usrbinslot

	db_src_install_headerslot

	db_src_install_doc

	db_src_install_usrlibcleanup

	dodir /usr/sbin
	# This file is not always built, and no longer exists as of db-4.8
	[[ -f "${ED}"/usr/bin/berkeley_db_svc ]] && \
	mv "${ED}"/usr/bin/berkeley_db_svc "${ED}"/usr/sbin/berkeley_db"${SLOT/./}"_svc

	if use java; then
		java-pkg_regso "${ED}"/usr/"$(get_libdir)"/libdb_java*.so
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
