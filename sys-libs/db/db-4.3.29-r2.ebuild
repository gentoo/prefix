# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/db/db-4.3.29-r2.ebuild,v 1.12 2007/04/23 11:37:10 armin76 Exp $

EAPI="prefix"

inherit eutils gnuconfig db flag-o-matic java-pkg-opt-2

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
DESCRIPTION="Berkeley DB"
HOMEPAGE="http://www.sleepycat.com/"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
#SRC_URI="ftp://ftp.sleepycat.com/releases/${MY_P}.tar.gz"
for (( i=1 ; i<=${PATCHNO} ; i++ )) ; do
	export SRC_URI="${SRC_URI} http://www.sleepycat.com/update/${MY_PV}/patch.${MY_PV}.${i}"
done

LICENSE="DB"
SLOT="4.3"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="tcl java doc nocxx bootstrap"

DEPEND="tcl? ( >=dev-lang/tcl-8.4 )
	java? ( >=virtual/jdk-1.4 )
	!elibc_Darwin? ( >=sys-devel/binutils-2.16.1 )"
RDEPEND="tcl? ( dev-lang/tcl )
	java? ( >=virtual/jre-1.4 )"

src_unpack() {
	unpack "${MY_P}".tar.gz
	cd "${WORKDIR}"/"${MY_P}"
	for (( i=1 ; i<=${PATCHNO} ; i++ ))
	do
		epatch "${DISTDIR}"/patch."${MY_PV}"."${i}"
	done
	epatch "${FILESDIR}"/"${PN}"-"${SLOT}"-libtool.patch

	epatch "${FILESDIR}"/"${PN}"-4.3.27-fix-dep-link.patch

	# use the includes from the prefix
	epatch "${FILESDIR}"/"${PN}"-"${SLOT}"-jni-check-prefix-first.patch
	epatch "${FILESDIR}"/"${PN}"-"${SLOT}"-listen-to-java-options.patch

	gnuconfig_update "${S}"/../dist

	sed -i \
		-e "s,\(ac_compiler\|\${MAKEFILE_CC}\|\${MAKEFILE_CXX}\|\$CC\)\( *--version\),\1 -dumpversion,g" \
		"${S}"/../dist/configure
}

src_compile() {
	local myconf=""

	use amd64 && myconf="${myconf} --with-mutex=x86/gcc-assembly"

	use bootstrap \
		&& myconf="${myconf} --disable-cxx" \
		|| myconf="${myconf} $(use_enable !nocxx cxx)"

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
	if use tcl && has test $FEATURES ; then
		myconf="${myconf} --enable-test"
	else
		myconf="${myconf} --disable-test"
	fi

	# Add linker versions to the symbols. Easier to do, and safer than header file
	# mumbo jumbo.
	if use userland_GNU; then
		append-ldflags -Wl,--default-symver
	fi

	../dist/configure \
		--prefix=${EPREFIX}/usr \
		--mandir=${EPREFIX}/usr/share/man \
		--infodir=${EPREFIX}/usr/share/info \
		--datadir=${EPREFIX}/usr/share \
		--sysconfdir=${EPREFIX}/etc \
		--localstatedir=${EPREFIX}/var/lib \
		--libdir=${EPREFIX}/usr/"$(get_libdir)" \
		--enable-compat185 \
		--without-uniquename \
		--enable-rpc \
		--host="${CHOST}" \
		${myconf}  "${javaconf}" || die "configure failed"

	emake -j1 || die "make failed"
}

src_install() {
	einstall libdir="${ED}/usr/$(get_libdir)" strip="${ED}/bin/strip"  || die

	db_src_install_usrbinslot

	db_src_install_headerslot

	db_src_install_doc

	db_src_install_usrlibcleanup

	dodir /usr/sbin
	mv "${ED}"/usr/bin/berkeley_db_svc "${ED}"/usr/sbin/berkeley_db43_svc

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
