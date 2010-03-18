# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/apache-tools/apache-tools-2.2.14.ebuild,v 1.8 2010/03/07 11:45:33 hollow Exp $

inherit flag-o-matic eutils

DESCRIPTION="Useful Apache tools - htdigest, htpasswd, ab, htdbm"
HOMEPAGE="http://httpd.apache.org/"
SRC_URI="mirror://apache/httpd/httpd-${PV}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc64-solaris ~x64-solaris"
IUSE="ssl"
RESTRICT="test"

RDEPEND="=dev-libs/apr-1*
	=dev-libs/apr-util-1*
	dev-libs/libpcre
	ssl? ( dev-libs/openssl )
	!<www-servers/apache-2.2.4"

DEPEND="${RDEPEND}"

S="${WORKDIR}/httpd-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Apply these patches:
	# (1)	apache-tools-Makefile.patch:
	#		- fix up the `make install' for support/
	#		- remove envvars from `make install'
	epatch "${FILESDIR}"/${PN}-Makefile.patch
}

src_compile() {
	local myconf=""
	cd "${S}"

	# Instead of filtering --as-needed (bug #128505), append --no-as-needed
	# Thanks to Harald van Dijk
	append-ldflags $(no-as-needed)

	if use ssl ; then
		myconf="${myconf} --with-ssl=${EPREFIX}/usr --enable-ssl"
	fi

	# econf overwrites the stuff from config.layout, so we have to put them into
	# our myconf line too
	econf \
		--sbindir="${EPREFIX}"/usr/sbin \
		--with-perl="${EPREFIX}"/usr/bin/perl \
		--with-expat="${EPREFIX}"/usr \
		--with-z="${EPREFIX}"/usr \
		--with-apr="${EPREFIX}"/usr \
		--with-apr-util="${EPREFIX}"/usr \
		--with-pcre="${EPREFIX}"/usr \
		${myconf} || die "econf failed!"

	cd support
	emake || die "emake support/ failed!"
}

src_install () {
	cd "${S}"/support

	make DESTDIR="${D}" install || die "make install failed!"

	# install manpages
	doman "${S}"/docs/man/{dbmmanage,htdigest,htpasswd,htdbm}.1 \
		"${S}"/docs/man/{ab,htcacheclean,logresolve,rotatelogs}.8

	# Providing compatiblity symlinks for #177697 (which we'll stop to install
	# at some point).

	for i in $(ls "${ED}"/usr/sbin 2>/dev/null); do
		dosym /usr/sbin/${i} /usr/sbin/${i}2
	done

	# Provide a symlink for ab-ssl
	if use ssl ; then
		dosym /usr/sbin/ab /usr/sbin/ab-ssl
		dosym /usr/sbin/ab /usr/sbin/ab2-ssl
	fi

	# make htpasswd accessible for non-root users
	dosym /usr/sbin/htpasswd /usr/bin/htpasswd
	dosym /usr/sbin/htdigest /usr/bin/htdigest

	dodoc "${S}"/CHANGES
}
