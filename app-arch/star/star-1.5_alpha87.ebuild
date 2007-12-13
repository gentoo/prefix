# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/star/star-1.5_alpha87.ebuild,v 1.6 2007/12/12 16:15:30 jer Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="An enhanced (world's fastest) tar, as well as enhanced mt/rmt"
HOMEPAGE="http://cdrecord.berlios.de/old/private/star.html"
SRC_URI="ftp://ftp.berlios.de/pub/${PN}/alpha/${PN}-${PV/_alpha/a}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1 CDDL-Schily"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

S=${WORKDIR}/${P/_alpha[0-9][0-9]}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cd "${S}"/DEFAULTS
	sed -i \
		-e "s:/opt/schily:${EPREFIX}/usr:g" \
		-e 's:bin:root:g' \
		-e "s:/usr/src/linux/include:${EPREFIX}/usr/include:" \
		Defaults.linux

	if use amd64 ; then
		cd "${S}"/RULES
		cp i386-linux-cc.rul x86_64-linux-cc.rul
		cp i386-linux-gcc.rul x86_64-linux-gcc.rul
	fi

	if use ppc64 ; then
		cd "${S}"/RULES
		cp ppc-linux-cc.rul ppc64-linux-cc.rul
		cp ppc-linux-gcc.rul ppc64-linux-gcc.rul
	fi

}

src_compile() {
	make CC="$(tc-getCC)" COPTX="${CFLAGS}" CPPOPTX="${CPPFLAGS}" LDOPTX="${LDFLAGS}" || die
}

src_install() {
	# Joerg Schilling suggested to integrate star into the main OS using call:
	# make INS_BASE=/usr DESTDIR="${D}" install

	dobin star/OBJ/*-*-cc/star || die "dobin star failed"
	dobin tartest/OBJ/*-*-cc/tartest || die "dobin tartest failed"
	dobin star_sym/OBJ/*-*-cc/star_sym || die "dobin star_sym failed"
	dobin mt/OBJ/*-*-cc/smt || die "dobin smt failed"

	newsbin rmt/OBJ/*-*-cc/rmt rmt.star
	newman rmt/rmt.1 rmt.star.1

	# Note that we should never install gnutar, tar or rmt in this package.
	# tar and rmt are provided by app-arch/tar. gnutar is not compatible with
	# GNU tar and breakes compilation, or init scripts. bug #33119
	dosym /usr/bin/{star,ustar}
	dosym /usr/bin/{star,spax}
	dosym /usr/bin/{star,scpio}
	dosym /usr/bin/{star,suntar}

	#  match is needed to understand the pattern matcher, if you wondered why ;)
	mv star/{star.4,star.5}
	doman man/man1/match.1 tartest/tartest.1 \
		star/{star.5,star.1,spax.1,scpio.1,suntar.1}

	insinto /etc/default
	newins star/star.dfl star
	newins rmt/rmt.dfl rmt

	dodoc star/{README.ACL,README.crash,README.largefiles,README.otherbugs} \
		star/{README.pattern,README.pax,README.posix-2001,README,STARvsGNUTAR} \
			rmt/default-rmt.sample TODO AN-* Changelog CONTRIBUTING
}
