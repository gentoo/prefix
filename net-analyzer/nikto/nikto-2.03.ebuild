# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/nikto/nikto-2.03.ebuild,v 1.1 2009/03/20 16:02:06 dertobi123 Exp $

DESCRIPTION="Web Server vulnerability scanner."
HOMEPAGE="http://www.cirt.net/code/nikto.shtml"
SRC_URI="http://www.cirt.net/source/nikto/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="ssl"

RDEPEND="dev-lang/perl
		>=net-analyzer/nmap-3.00
		ssl? (
			dev-libs/openssl
			dev-perl/Net-SSLeay
		)"

src_compile() {
	cd nikto

	mv config.txt nikto.conf

	sed -i -e 's:config.txt:nikto.conf:g' \
		plugins/* docs/nikto.1 nikto.pl

	sed	-i -e 's:config.txt:nikto.conf:' \
		-i -e 's:\($NIKTO{configfile} = \)"nikto.conf":\1"'"${EPREFIX}"'/etc/nikto/nikto.conf":' \
		-i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl' \
		nikto.pl

	sed -i -e 's:/usr/local/bin/nmap:'"${EPREFIX}"'/usr/bin/nmap:' \
		-i -e 's:# EXECDIR=/usr/local/nikto:EXECDIR='"${EPREFIX}"'/usr/share/nikto:' \
		nikto.conf

	rm -rf $(find -name .svn -type d)
}

src_install() {
	cd nikto

	insinto /etc/nikto
	doins nikto.conf

	dobin nikto.pl
	dosym /usr/bin/nikto.pl /usr/bin/nikto

	dodir /usr/share/nikto
	insinto /usr/share/nikto
	doins -r plugins templates

	dodoc plugins/nikto_plugin_order.txt
	dodoc docs/*.txt
	dohtml docs/nikto_manual.html
}
