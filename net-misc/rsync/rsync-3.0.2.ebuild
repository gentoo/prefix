# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/rsync-3.0.2.ebuild,v 1.1 2008/04/08 17:26:12 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs autotools

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRC_URI="http://rsync.samba.org/ftp/rsync/${P/_/}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl ipv6 static xattr xinetd"

DEPEND=">=dev-libs/popt-1.5
	acl? ( kernel_linux? ( sys-apps/acl ) )
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	xinetd? ( sys-apps/xinetd )"

S=${WORKDIR}/${P/_/}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}"/rsyncd.* "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/rsync-files-prefix.patch
	eprefixify rsyncd.*
}

src_compile() {
	use static && append-ldflags -static
	econf \
		--without-included-popt \
		$(use_enable acl acl-support) \
		$(use_enable xattr xattr-support) \
		$(use_enable ipv6) \
		--with-rsyncd-conf="${EPREFIX}"/etc/rsyncd.conf \
		|| die
	emake || die "emake failed"
}

pkg_preinst() {
	if [[ -e ${EROOT}/etc/rsync/rsyncd.conf ]] && [[ ! -e ${EROOT}/etc/rsyncd.conf ]] ; then
		mv "${EROOT}"/etc/rsync/rsyncd.conf "${EROOT}"/etc/rsyncd.conf
		rm -f "${EROOT}"/etc/rsync/.keep
		rmdir "${EROOT}"/etc/rsync >& /dev/null
	fi
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
	ewarn "The rsyncd.conf file has been moved for you to ${EPREFIX}/etc/rsyncd.conf"
	echo
	ewarn "Please make sure you do NOT disable the rsync server running"
	ewarn "in a chroot.  Please check ${EPREFIX}/etc/rsyncd.conf and make sure"
	ewarn "it says: use chroot = yes"
}
