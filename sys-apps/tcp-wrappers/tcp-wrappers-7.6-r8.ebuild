# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/tcp-wrappers/tcp-wrappers-7.6-r8.ebuild,v 1.21 2006/10/17 14:42:02 uberlord Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

MY_P="${P//-/_}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="TCP Wrappers"
HOMEPAGE="ftp://ftp.porcupine.org/pub/security/index.html"
SRC_URI="ftp://ftp.porcupine.org/pub/security/${MY_P}.tar.gz
	mirror://gentoo/${PF}-patches.tar.bz2"

LICENSE="tcp_wrappers_license"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"

RDEPEND="virtual/libc"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack ${A}
	cd ${S}

	chmod ug+w Makefile
	sed -i \
		-e "s:-O:${CFLAGS}:" \
		-e "s:AUX_OBJ=.*:AUX_OBJ= \\\:" \
		Makefile || die "makefile patch prep"

	PATCHDIR=${WORKDIR}/${PV}-patches
	epatch ${PATCHDIR}/${P}-makefile.patch.bz2
	epatch ${PATCHDIR}/generic
	epatch ${PATCHDIR}/${P}-shared.patch.bz2
	use ipv6 && epatch ${PATCHDIR}/${P}-ipv6-1.14.diff.bz2

	# make it parallel/cross-compile friendly.
	sed -i \
		-e 's:gcc:$(CC):' \
		-e 's:@make :@$(MAKE) :' \
		-e 's:make;:$(MAKE);:' \
		Makefile || die "sed Makefile failed"
}

src_compile() {
	tc-export CC

	local myconf="-DHAVE_WEAKSYMS"
	use ipv6 && myconf="${myconf} -DINET6=1 -Dss_family=__ss_family -Dss_len=__ss_len"

	emake \
		REAL_DAEMON_DIR=/usr/sbin \
		GENTOO_OPT="${myconf}" \
		MAJOR=0 MINOR=${PV:0:1} REL=${PV:2:3} \
		config-check || die "emake config-check failed"

	emake \
		REAL_DAEMON_DIR=/usr/sbin \
		GENTOO_OPT="${myconf}" \
		MAJOR=0 MINOR=${PV:0:1} REL=${PV:2:3} \
		linux || die "emake linux failed"
}

src_install() {
	dosbin tcpd tcpdchk tcpdmatch safe_finger try-from || die

	doman *.[358]
	dosym hosts_access.5.gz /usr/share/man/man5/hosts.allow.5.gz
	dosym hosts_access.5.gz /usr/share/man/man5/hosts.deny.5.gz

	insinto /usr/include
	doins tcpd.h

	into /usr
	dolib.a libwrap.a

	into /
	newlib.so libwrap.so libwrap.so.0.${PV}
	dosym /$(get_libdir)/libwrap.so.0.${PV} /$(get_libdir)/libwrap.so.0
	dosym /$(get_libdir)/libwrap.so.0 /$(get_libdir)/libwrap.so
	# bug #4411
	gen_usr_ldscript libwrap.so || die "gen_usr_ldscript failed"

	dodoc BLURB CHANGES DISCLAIMER README* ${FILESDIR}/hosts.allow.example
}
