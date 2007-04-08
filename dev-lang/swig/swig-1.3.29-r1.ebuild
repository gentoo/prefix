# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swig/swig-1.3.29-r1.ebuild,v 1.5 2007/02/11 14:23:10 grobian Exp $

EAPI="prefix"

inherit flag-o-matic mono eutils #48511

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="http://www.swig.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc guile java lua mono ocaml perl php pike python ruby tcl tk"
RESTRICT="test"

DEPEND="lua? ( dev-lang/lua )
	guile? ( >=dev-scheme/guile-1.4 )
	java? ( virtual/jdk )
	mono? ( dev-lang/mono )
	perl? ( >=dev-lang/perl-5.6.1 )
	php? ( virtual/php )
	pike? ( dev-lang/pike )
	python? ( virtual/python )
	ocaml? ( dev-lang/ocaml )
	ruby? ( virtual/ruby )
	tcl? ( dev-lang/tcl )
	tk? ( dev-lang/tk )"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	# const char type casting issue prevention
	epatch "${FILESDIR}"/swig-const.patch
}

src_compile() {
	strip-flags

	local myconf
	if use ruby ; then
		local rubyver=$(ruby --version | cut -d '.' -f 1,2)
		export RUBY="${EPREFIX}/usr/$(get_libdir)/ruby/${rubyver/ruby /}/"
	fi

	econf \
		$(use_with tk x) \
		$(use_with tcl) \
		$(use_with python python python) \
		$(use_with perl perl5 /usr/bin/perl) \
		$(use_with java java "${JAVA_HOME}") \
		$(use_with java javaincl "${JAVA_HOME}/include") \
		$(use_with guile) \
		$(use_with ruby ruby /usr/bin/ruby) \
		$(use_with php php4) \
		$(use_with ocaml) \
		$(use_with pike) \
		$(use_with mono csharp) \
		$(use_with lua) \
		|| die

	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc ANNOUNCE CHANGES CHANGES.current FUTURE NEW README TODO
	use doc && dohtml -r Doc/{Devel,Manual}
}
