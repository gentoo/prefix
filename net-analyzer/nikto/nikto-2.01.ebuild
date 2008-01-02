# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/nikto/nikto-2.01.ebuild,v 1.1 2007/12/28 10:48:14 dertobi123 Exp $

EAPI="prefix"

DESCRIPTION="Web Server vulnerability scanner."
HOMEPAGE="http://www.cirt.net/code/nikto.shtml"
SRC_URI="http://www.cirt.net/source/nikto/ARCHIVE/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="ssl"

RDEPEND="dev-lang/perl
		>=net-analyzer/nmap-3.00
		ssl? (
			dev-libs/openssl
			dev-perl/Net-SSLeay
		)"

src_compile() {
	sed	-i -e 's:config.txt:nikto.conf:' \
		-i -e 's:"\$NIKTO{execdir}/kbase/nikto.kbase":"'"${EPREFIX}"'/var/nikto/kbase/nikto.kbase":' \
		-i -e 's:\$NIKTO{configfile} = "nikto.conf":\$NIKTO{configfile} = "'"${EPREFIX}"'/etc/nikto/nikto.conf":' \
		-i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl' \
		 nikto.pl

	mv config.txt nikto.conf

	sed -i -e 's:/usr/local/bin/nmap:'"${EPREFIX}"'/usr/bin/nmap:' \
		-i -e 's:# EXECDIR=/usr/local/nikto:EXECDIR='"${EPREFIX}"'/usr/share/nikto:' \
		 nikto.conf
}

src_install() {
	insinto /etc/nikto
	doins nikto.conf

	dodir /usr/bin
	dobin nikto.pl
	dosym /usr/bin/nikto.pl /usr/bin/nikto

	dodir /usr/share/nikto/plugins
	insinto /usr/share/nikto/plugins
	doins plugins/*

	dodir /usr/share/nikto/templates
	insinto /usr/share/nikto/templates
	doins templates/*

	dodir /var/nikto/kbase

	dodoc plugins/nikto_plugin_order.txt
	cd docs
	dodoc CHANGES.txt LICENSE.txt
	dohtml nikto_manual.html
}
