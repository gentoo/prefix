# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xerces-c/xerces-c-3.1.1.ebuild,v 1.1 2010/08/28 06:25:10 dev-zero Exp $

EAPI=2

inherit eutils

DESCRIPTION="A validating XML parser written in a portable subset of C++."
HOMEPAGE="http://xerces.apache.org/xerces-c/"
SRC_URI="mirror://apache/xerces/c/3/sources/${P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE="curl doc iconv icu libwww sse2 static-libs threads elibc_Darwin elibc_FreeBSD"

RDEPEND="icu? ( >=dev-libs/icu-4.2 )
	curl? ( net-misc/curl )
	libwww? ( net-libs/libwww )
	virtual/libiconv"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

pkg_setup() {
	export ICUROOT="${EPREFIX}/usr"

	if use iconv && use icu ; then
		ewarn "This package can use iconv or icu for loading messages"
		ewarn "and transcoding, but not both. ICU will precede."
	fi
}

src_prepare() {
	use threads || epatch "${FILESDIR}/${PV}-disable-thread-tests.patch"

	sed -i \
		-e 's|$(prefix)/msg|$(DESTDIR)/$(prefix)/share/xerces-c/msg|' \
		src/xercesc/util/MsgLoaders/MsgCatalog/Makefile.in || die "sed failed"
}

src_configure() {
	local mloader="inmemory"
	use iconv && mloader="iconv"
	use icu && mloader="icu"

	local transcoder="gnuiconv"
	use elibc_FreeBSD && transcoder="iconv"
	use elibc_Darwin && transcoder="macosunicodeconverter"
	use icu && transcoder="icu"
	# for interix maybe: transcoder="windows"

	# 'cfurl' is only available on OSX and 'socket' isn't supposed to work.
	# But the docs aren't clear about it, so we would need some testing...
	local netaccessor="socket"
	use elibc_Darwin && netaccessor="cfurl"
	use libwww && netaccessor="libwww"
	use curl && netaccessor="curl"

	econf \
		--disable-pretty-make \
		$(use_enable static-libs static) \
		$(use_enable threads) \
		$(use_with curl curl "${EPREFIX}"/usr) \
		$(use_with icu icu "${EPREFIX}"/usr) \
		--enable-msgloader-${mloader} \
		--enable-netaccessor-${netaccessor} \
		--enable-transcoder-${transcoder} \
		$(use_enable sse2)
}

src_compile() {
	default

	if use doc ; then
		cd "${S}/doc"
		doxygen || die "making docs failed"
	fi
}

src_install () {
	emake DESTDIR="${D}" install || die "emake failed"

	use static-libs || rm "${ED}"/usr/lib*/*.la

	# To make sure an appropriate NLS msg file is around when using the iconv msgloader
	# ICU has the messages compiled in.
	if use iconv && ! use icu ; then
		cd "${S}"
		cp "${FILESDIR}/50xerces-c" .
		sed -i -e '/XERCESC_NLS_HOME/s:=":="'"${EPREFIX}"':' 50xerces-c
		doenvd 50xerces-c
	fi

	if use doc; then
		insinto /usr/share/doc/${PF}
		rm -rf samples/Makefile* samples/runConfigure samples/src/*/Makefile* samples/.libs
		doins -r samples
		dohtml -r doc/html/*
	fi

	dodoc CREDITS KEYS NOTICE README version.incl
}
