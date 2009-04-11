# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/slocate/slocate-3.1-r2.ebuild,v 1.1 2008/08/19 01:11:18 vapier Exp $

inherit flag-o-matic eutils prefix

DESCRIPTION="Secure way to index and quickly search for files on your system (drop-in replacement for 'locate')"
HOMEPAGE="http://slocate.trakker.ca/"
SRC_URI="http://slocate.trakker.ca/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-apps/shadow"
RDEPEND="${DEPEND}
	!sys-apps/rlocate"

pkg_setup() {
	if [[ -n $(egetent group slocate) ]] && [[ -z $(egetent group locate) ]] ; then
		eerror "The 'slocate' group has been renamed to 'locate'."
		eerror "You seem to already have a 'slocate' group."
		eerror "Please rename it:"
		eerror "groupmod -n locate slocate"
		die "Change 'slocate' to 'locate'"
	fi
	enewgroup locate 245
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-incompat-warning.patch
	epatch "${FILESDIR}"/${P}-CVE-2007-0227.patch
	epatch "${FILESDIR}"/${P}-cron2.patch
	epatch "${FILESDIR}"/${P}-NUL.patch #216838

	epatch "${FILESDIR}"/${P}-build-prefix.patch                            
	epatch "${FILESDIR}"/${P}-cron2-prefix.patch                             
	eprefixify src/slocate.h debian/cron.daily
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	filter-lfs-flags
	[[ ${CHOST} == *-linux-gnu ]] && append-flags "-DHAVE_STRNDUP"
	emake -C src || die
}

src_install() {
	dobin src/slocate || die
	dodir /usr/bin
	dosym slocate /usr/bin/locate
	dosym slocate /usr/bin/updatedb

	exeinto /etc/cron.daily
	newexe debian/cron.daily slocate || die

	doman doc/*.1
	dosym slocate.1 /usr/share/man/man1/locate.1

	keepdir /var/lib/slocate

	dodoc Changelog README WISHLIST notes

	insinto /etc
	doins "${FILESDIR}"/updatedb.conf

	fowners root:locate /usr/bin/slocate
	fperms go-r,g+s /usr/bin/slocate

	chown -R root:locate "${ED}"/var/lib/slocate
	fperms 0750 /var/lib/slocate
}

pkg_preinst() {
	if has_version '=sys-apps/slocate-2*' ; then
		rm -f "${EROOT}"/var/lib/slocate/slocate.db
		ewarn "The slocate database created by slocate-2.x is incompatible"
		ewarn "with slocate-3.x.  Make sure you run updatedb!"
	fi
}

pkg_postinst() {
	if [[ -f ${EROOT}/etc/cron.daily/slocate.cron ]]; then
		ewarn "If you merged slocate-2.7.ebuild, please remove"
		ewarn "/etc/cron.daily/slocate.cron since .cron has been removed"
		ewarn "from the filename"
		echo
	fi
}
