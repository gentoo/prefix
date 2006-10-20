# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/rsync-2.6.8-r2.ebuild,v 1.4 2006/10/17 11:40:22 uberlord Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRC_URI="http://rsync.samba.org/ftp/rsync/${P/_/}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="acl build ipv6 static xinetd"

RDEPEND="!build? ( >=dev-libs/popt-1.5 )
	acl? ( kernel_linux? ( sys-apps/acl ) )"
DEPEND="${RDEPEND}
	>=sys-apps/portage-2.0.51"

S=${WORKDIR}/${P/_/}

src_unpack() {
	unpack ${P/_/}.tar.gz
	cd "${S}"
	epatch "${FILESDIR}"/${P}-fix-deferred-msgs.patch #133054
	epatch "${FILESDIR}"/${P}-verbose-quiet-output.patch #133217
	if use acl ; then
		epatch patches/{acls,xattrs}.diff
		./prepare-source || die
	fi
}

src_compile() {
	[[ $(gcc-version) == "2.95" ]] && append-ldflags -lpthread
	use static && append-ldflags -static

	econf \
		$(use_with build included-popt) \
		$(use_enable acl acl-support) \
		$(use_enable acl xattr-support) \
		$(use_enable ipv6) \
		--with-rsyncd-conf="${EPREFIX}"/etc/rsyncd.conf \
		|| die
	emake || die "emake failed"
}

pkg_preinst() {
	if [[ -e ${ROOT}/etc/rsync/rsyncd.conf ]] && [[ ! -e ${ROOT}/etc/rsyncd.conf ]] ; then
		mv "${ROOT}"/etc/rsync/rsyncd.conf "${ROOT}"/etc/rsyncd.conf
		rm -f "${ROOT}"/etc/rsync/.keep
		rmdir "${ROOT}"/etc/rsync >& /dev/null
	fi
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed"
	newconfd "${FILESDIR}"/rsyncd.conf.d rsyncd
	cp "${FILESDIR}"/rsyncd.init.d "${T}"/rsyncd.init.d
	ebegin "Adjusting to prefix"
	sed -i \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
		"${T}"/rsyncd.init.d
	eend $?
	newinitd "${T}"/rsyncd.init.d rsyncd
	if ! use build ; then
		dodoc NEWS OLDNEWS README TODO tech_report.tex
		insinto /etc
		doins "${FILESDIR}"/rsyncd.conf
		ebegin "Adjusting to prefix"
		dosed \
			"s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
			/etc/rsyncd.conf
		eend $?
		if use xinetd ; then
			insinto /etc/xinetd.d
			newins "${FILESDIR}"/rsyncd.xinetd rsyncd
			ebegin "Adjusting to prefix"
			dosed \
				"s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
				/etc/xinetd.d/rsyncd
			eend $?
			fi
	else
		rm -r "${D}"/usr/share
	fi
}

pkg_postinst() {
	ewarn "The rsyncd.conf file has been moved for you to /etc/rsyncd.conf"
	echo
	ewarn "Please make sure you do NOT disable the rsync server running"
	ewarn "in a chroot.  Please check /etc/rsyncd.conf and make sure"
	ewarn "it says: use chroot = yes"
}
