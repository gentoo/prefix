# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xerces-c/xerces-c-2.8.0-r1.ebuild,v 1.4 2008/10/25 17:48:58 halcy0n Exp $

EAPI=1

inherit eutils multilib versionator flag-o-matic toolchain-funcs

MY_PN="xerces-c-src"
MY_P=${MY_PN}_$(replace_all_version_separators _)

DESCRIPTION="A validating XML parser written in a portable subset of C++."
HOMEPAGE="http://xerces.apache.org/xerces-c/"
SRC_URI="mirror://apache/xerces/c/2/sources/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug doc icu libwww +threads elibc_Darwin elibc_FreeBSD xqilla"

RDEPEND="icu? ( <dev-libs/icu-3.8 )
	libwww? ( net-libs/libwww )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	export ICUROOT="${EPREFIX}/usr"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e 's|sh ./configure.*|true|' \
		src/xercesc/runConfigure || die "sed failed"

	sed -i \
		-e 's|-L/usr/lib64 -L/usr/lib -L/usr/local/lib -L/usr/ccs/lib|-L${XERCESCROOT}/lib|g' \
		-e 's|-L/usr/lib -L/usr/local/lib -L/usr/ccs/lib|-L${XERCESCROOT}/lib|g' \
		-e 's|-L/usr/lib|-L${XERCESCROOT}/lib|g' \
		{samples,src/xercesc,tests}/Makefile.incl || die "sed for fixing library include path failed"

	sed -i \
		-e 's|${PREFIX}/lib|${PREFIX}/${MLIBDIR}|g' \
		-e 's|$(PREFIX)/lib|$(PREFIX)/${MLIBDIR}|g' \
		obj/Makefile.in src/xercesc/Makefile.incl || die "sed for fixing install lib dir failed"

	sed -i \
		-e 's|$(PREFIX)/msg|$(PREFIX)/share/xerces-c/msg|g' \
		-e 's|${PREFIX}/msg|${PREFIX}/share/xerces-c/msg|g' \
		src/xercesc/util/Makefile.in || die "sed for changing message catalogue directory failed"

	epatch \
		"${FILESDIR}/${P}-64bit_cast.patch" \
		"${FILESDIR}/${P}-icu_ressource_fix.patch" \
		"${FILESDIR}/${P}-IconvGNUTransService.cpp.patch"

	use xqilla && epatch \
		"${FILESDIR}/xqilla-xercesc_content_type.patch" \
		"${FILESDIR}/xqilla-xercesc_regex.patch"

}

src_compile() {
	export XERCESCROOT="${S}"
	cd src/xercesc

	local myconf
	use debug && myconf="-d"

	local bitstobuild="32"
	$(has_m64) && bitstobuild="64"

	# We need a case-switch here for other platforms,
	# but we wait until there's a real use case
	local target="linux"
	use elibc_FreeBSD && target="freebsd"
	use elibc_Darwin && target="macosx"

	local mloader="inmem"
	use icu && mloader="icu"

	local transcoder="native"
	use icu && transcoder="icu"

	# Other options are available for AIX, HP-11, IRIX or Solaris
	local thread="none"
	use threads && thread="pthread"

	# 'native' is only available on OSX (see use.mask) and 'socket'
	# isn't supposed to work. But the docs aren't clear about it, so
	# we would need some testing...
	local netaccessor="socket"
	use elibc_Darwin && netaccessor="native"
	use libwww && netaccessor="libwww"

	./runConfigure -p ${target} -c "$(tc-getCC)" -x "$(tc-getCXX)" \
		${myconf} -m ${mloader} -n ${netaccessor} -t ${transcoder} \
		-r ${thread} -b ${bitstobuild} > configure.vars || die "runConfigure failed"

	# This should be safe since runConfigure includes our C[XX]FLAGS
	eval $(grep export configure.vars)
	econf || die "econf failed"
	# Parallel building is horribly broken when not using --as-needed
	emake -j1 MLIBDIR=$(get_libdir) || die "emake failed"

	if use doc ; then
		cd "${S}/doc"
		doxygen || die "making docs failed"
	fi
}

src_install () {
	export XERCESCROOT="${S}"
	cd src/xercesc
	emake DESTDIR="${D}" MLIBDIR=$(get_libdir) install || die "emake failed"

	if use xqilla; then
		insinto /usr/include/xercesc/dom/impl
		cd dom/impl
		doins \
			DOMAttrImpl.hpp DOMAttrMapImpl.hpp DOMCasts.hpp DOMCharacterDataImpl.hpp \
			DOMChildNode.hpp DOMDeepNodeListPool.hpp DOMDocumentImpl.hpp \
			DOMDocumentTypeImpl.hpp DOMElementImpl.hpp DOMElementNSImpl.hpp \
			DOMNodeIDMap.hpp DOMNodeImpl.hpp DOMNodeListImpl.hpp DOMParentNode.hpp \
			DOMRangeImpl.hpp DOMTextImpl.hpp DOMTypeInfoImpl.hpp DOMWriterImpl.hpp
	fi

	cd "${S}"
	cp "${FILESDIR}/50xerces-c" .
	sed -i -e '/XERCESC_NLS_HOME/s:=":="'"${EPREFIX}"':' 50xerces-c
	doenvd 50xerces-c

	# Upstream forgot this
	if use icu ; then
		dolib.so lib/libXercesMessages.so.28.0
		dosym libXercesMessages.so.28.0 /usr/$(get_libdir)/libXercesMessages.so.28
		dosym libXercesMessages.so.28.0 /usr/$(get_libdir)/libXercesMessages.so
	fi

	if use doc; then
		insinto /usr/share/doc/${PF}
		rm -rf samples/config* samples/Makefile* samples/runConfigure samples/install-sh samples/*/Makefile*
		doins -r samples
		dohtml -r doc/html/*
	fi

	dodoc STATUS credits.txt version.incl
	dohtml Readme.html

	unset XERCESCROOT
}

# There are tests available, but without a script to run them
