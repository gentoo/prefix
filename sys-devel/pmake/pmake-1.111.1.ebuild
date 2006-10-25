# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/pmake/pmake-1.111.1.ebuild,v 1.5 2006/10/14 14:26:15 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs versionator

MY_P="${PN}-$(get_version_component_range 1-2)"
DEBIAN_SOURCE="${PN}_$(get_version_component_range 1-2).orig.tar.gz"
DEBIAN_PATCH="${PN}_$(replace_version_separator 2 '-').diff.gz"

DESCRIPTION="BSD build tool to create programs in parallel. Debian's version of NetBSD's make"
HOMEPAGE="http://www.netbsd.org/"
SRC_URI="mirror://debian/pool/main/p/pmake/${DEBIAN_SOURCE}
	mirror://debian/pool/main/p/pmake/${DEBIAN_PATCH}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

RDEPEND="!sys-devel/bmake"
DEPEND=""

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}/${DEBIAN_PATCH/.gz/}"

	# pmake makes the assumption that . and .. are the first two
	# entries in a directory, which doesn't always appear to be the
	# case on ext3...  (05 Apr 2004 agriffis)
	epatch "${FILESDIR}/${PN}-1.98-skipdots.patch"

	# Add inttypes.h header on OpenBSD
	epatch "${FILESDIR}/${P}-obsd-inttypes.patch"

	# Clean up headers to reduce warnings
	sed -i -e 's|^#endif.*|#endif|' *.h */*.h
}

src_compile() {
	# The following CFLAGS are almost directly from Red Hat 8.0 and
	# debian/rules, so assume it's okay to void out the __COPYRIGHT
	# and __RCSID.  I've checked the source and don't see the point,
	# but whatever...  (07 Feb 2004 agriffis)
	CFLAGS="${CFLAGS} -Wall -Wno-unused -D_GNU_SOURCE \
		-DHAVE_STRERROR -DHAVE_STRDUP -DHAVE_SETENV \
		-D__COPYRIGHT\(x\)= -D__RCSID\(x\)= -I. \
		-DMACHINE=\\\"gentoo\\\" -DMACHINE_ARCH=\\\"$(tc-arch-kernel)\\\""

	make -f Makefile.boot \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		|| die "make failed"
}

src_install() {
	# Don't install these on BSD (or Darwin), else they conflicts
	if [[ "${USERLAND}" == "GNU" && ${EPREFIX%/} == "" ]]; then
		insinto /usr/share/mk
		doins mk/*
	fi

	newbin bmake pmake || die "newbin failed"
	dobin mkdep || die "dobin failed"
	mv make.1 pmake.1
	doman mkdep.1 pmake.1
	dodoc PSD.doc/tutorial.ms

	if [[ "${USERLAND}" == "BSD" ]]; then
		dosym pmake /usr/bin/make
		dosym pmake.1.gz /usr/share/man/man1/make.1.gz
	elif [[ "${USERLAND}" == "Darwin" ]]; then
		dosym pmake /usr/bin/bsdmake
		dosym pmake.1.gz /usr/share/man/man1/bsdmake.1.gz
	fi
}
