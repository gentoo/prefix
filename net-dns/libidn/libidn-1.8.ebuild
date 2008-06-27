# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/libidn/libidn-1.8.ebuild,v 1.1 2008/06/26 09:58:29 bangert Exp $

EAPI="prefix"

inherit java-pkg-opt-2 mono autotools elisp-common

DESCRIPTION="Internationalized Domain Names (IDN) implementation"
HOMEPAGE="http://www.gnu.org/software/libidn/"
SRC_URI="ftp://alpha.gnu.org/pub/gnu/libidn/${P}.tar.gz"

LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="java doc emacs mono nls"

DEPEND="mono? ( >=dev-lang/mono-0.95 )
	java? ( >=virtual/jdk-1.4 dev-java/gjdoc )"
RDEPEND="java? ( >=virtual/jre-1.4 )
	mono? ( >=dev-lang/mono-0.95 )
	emacs? ( virtual/emacs )"

src_unpack() {
	unpack ${A}
	# bundled, with wrong bytecode
	rm "${S}/java/${P}.jar" || die
}

src_compile() {
	local myconf=" --disable-csharp"

	use mono && myconf="--enable-csharp=mono"
	use emacs && myconf="${myconf} --with-lispdir=${SITELISP}/${PN}"

	econf \
		$(use_enable nls) \
		$(use_enable java) \
		${myconf} \
		|| die

	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog FAQ NEWS README THANKS TODO || die

	use emacs || rm -rf "${ED}/usr/share/emacs"
	#use xemacs || rm -rf "${ED}/usr/lib/xemacs"

	if use doc ; then
		dohtml -r doc/reference/html/* || die
	fi

	if use java ; then
		java-pkg_newjar "${ED}"/usr/share/java/${P}.jar || die
		rm -rf "${ED}"/usr/share/java || die

		if use doc ; then
			java-pkg_dojavadoc doc/java
		fi
	fi
}

pkg_postinst() {
	if use emacs ; then
		elog "activate Emacs support by adding the following lines"
		elog "to your ~/.emacs file:"
		elog "   (add-to-list 'load-path \"${SITELISP}/${PN}\")"
		elog "   (load idna)"
		elog "   (load punycode)"
	fi
}
