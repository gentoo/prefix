# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/rsync-3.0.6.ebuild,v 1.2 2009/05/29 19:59:09 flameeyes Exp $

inherit eutils flag-o-matic prefix

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRC_URI="http://rsync.samba.org/ftp/rsync/src/${P/_/}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl iconv ipv6 static xattr xinetd"

DEPEND=">=dev-libs/popt-1.5
	acl? ( virtual/acl )
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	xinetd? ( sys-apps/xinetd )
	iconv? ( virtual/libiconv )"

S=${WORKDIR}/${P/_/}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}"/rsyncd.* "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/rsync-files-prefix.patch
	eprefixify rsyncd.*

	local check base=${PORTAGE_CONFIGROOT}/etc/portage/patches
	for check in {${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}; do
		EPATCH_SOURCE=${base}/${CTARGET}/${check}
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=${base}/${CHOST}/${check}
		[[ -r ${EPATCH_SOURCE} ]] || EPATCH_SOURCE=${base}/${check}
		if [[ -d ${EPATCH_SOURCE} ]] ; then
			EPATCH_SUFFIX="patch"
			EPATCH_FORCE="yes" \
			EPATCH_MULTI_MSG="Applying user patches from ${EPATCH_SOURCE} ..." \
			epatch
			break
		fi
	done
}

src_compile() {
	use static && append-ldflags -static
	econf \
		--without-included-popt \
		$(use_enable acl acl-support) \
		$(use_enable xattr xattr-support) \
		$(use_enable ipv6) \
		$(use_enable iconv) \
		--with-rsyncd-conf="${EPREFIX}"/etc/rsyncd.conf \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	newconfd "${T}"/rsyncd.conf.d rsyncd
	newinitd "${T}"/rsyncd.init.d rsyncd
	dodoc NEWS OLDNEWS README TODO tech_report.tex
	insinto /etc
	doins "${T}"/rsyncd.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/rsyncd.logrotate rsyncd

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${T}"/rsyncd.xinetd rsyncd
	fi
}

pkg_postinst() {
	if egrep -qs '^[[:space:]]use chroot[[:space:]]*=[[:space:]]*(no|0|false)' \
		"${EROOT}"/etc/rsyncd.conf "${EROOT}"/etc/rsync/rsyncd.conf ; then
		ewarn "You have disabled chroot support in your rsyncd.conf.  This"
		ewarn "is a security risk which you should fix.  Please check your"
		ewarn "${EPREFIX}/etc/rsyncd.conf file and fix the setting 'use chroot'."
	fi
}
