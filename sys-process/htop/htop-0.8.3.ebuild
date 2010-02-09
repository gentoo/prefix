# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/htop/htop-0.8.3.ebuild,v 1.3 2010/02/01 20:29:40 hwoarang Exp $

EAPI="2"
inherit eutils flag-o-matic multilib

DESCRIPTION="interactive process viewer"
HOMEPAGE="http://htop.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="sys-libs/ncurses[unicode]"
RDEPEND="${DEPEND}"

pkg_setup() {
	if use elibc_FreeBSD && ! [[ -f "${EROOT}"/proc/stat && -f "${EROOT}"/proc/meminfo ]] ; then
		eerror
		eerror "htop needs /proc mounted to compile and work, to mount it type"
		eerror "mount -t linprocfs none /proc"
		eerror "or uncomment the example in /etc/fstab"
		eerror
		die "htop needs /proc mounted"
	fi

	if ! has_version sys-process/lsof ; then
		ewarn "To use lsof features in htop(what processes are accessing"
		ewarn "what files), you must have sys-process/lsof installed."
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.8.1-non-printable-char-filter.patch
}

src_configure() {
	useq debug && append-flags -O -ggdb -DDEBUG
	econf \
		--enable-taskstats \
		--enable-unicode
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README ChangeLog TODO || die "documentation installation failed."
	rmdir "${ED}"/usr/{include,$(get_libdir)} || die "Removing empty directory failed."
}
