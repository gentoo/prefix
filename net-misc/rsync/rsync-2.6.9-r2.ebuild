# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/rsync-2.6.9-r2.ebuild,v 1.6 2007/05/26 02:45:26 jer Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRC_URI="http://rsync.samba.org/ftp/rsync/${P/_/}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="acl ipv6 static xinetd"

DEPEND=">=dev-libs/popt-1.5
	acl? ( kernel_linux? ( sys-apps/acl ) )"

S=${WORKDIR}/${P/_/}

src_unpack() {
	unpack ${P/_/}.tar.gz
	cd "${S}"
	if use acl ; then
		epatch patches/{acls,xattrs}.diff
		epatch "${FILESDIR}"/${P}-delete-acls-xattr.patch
		./prepare-source || die
	fi
	epatch "${FILESDIR}"/${P}-stats-fix.patch #165121

	cp "${FILESDIR}"/rsyncd.* "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/rsync-files-prefix.patch
	eprefixify rsyncd.*
}

src_compile() {
	[[ $(gcc-version) == "2.95" ]] && append-ldflags -lpthread
	use static && append-ldflags -static

	econf \
		--without-included-popt \
		$(use_enable acl acl-support) \
		$(use_enable acl xattr-support) \
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
