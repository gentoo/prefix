# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Darwin assembler as(1) and static linker ld(1)"
HOMEPAGE="http://trac.macosforge.org/projects/odcctools"
SRC_URI="http://www.gentoo.org/~grobian/distfiles/${P}.tar.bz2"

LICENSE="APSL-2"
SLOT="0"

KEYWORDS="~ppc-macos ~x86-macos ~x86-solaris"

IUSE=""

DEPEND="sys-devel/binutils-config"
RDEPEND="${DEPEND}"

LIBPATH=/usr/$(get_libdir)/binutils/${CHOST}/${PV}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CHOST}/${PV}
BINPATH=/usr/${CHOST}/binutils-bin/${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [[ ${CHOST} != *-apple-darwin* ]] ; then
		# this patch should still allow for compilation on Darwin, but I don't
		# want of run the risk of breaking something, so I make sure it stays
		# vanilla on Darwin
		epatch "${FILESDIR}"/${P}-solaris.patch

		# ld64 depends on Darwin kernel headers, so its unlikely this can/will
		# compile
		sed -i -e '/^COMPONENTS=/s/ld64//' configure
	fi
}

src_compile() {
	myconf="\
		--host=${CHOST} \
		--build=${CBUILD} \
		--target=${CTARGET} \
		--prefix=${EPREFIX}/usr \
		--datadir=${EPREFIX}${DATAPATH} \
		--infodir=${EPREFIX}${DATAPATH}/info \
		--mandir=${EPREFIX}${DATAPATH}/man \
		--bindir=${EPREFIX}${BINPATH} \
		--libdir=${EPREFIX}${LIBPATH} \
		--libexecdir=${EPREFIX}${LIBPATH} \
		--includedir=${EPREFIX}${INCPATH}"
	echo -e "./configure ${myconf//--/\n\t--}"
	./configure ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die

	# Generate an env.d entry for this binutils
	cd "${S}"
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
		TARGET="${CHOST}"
		VER="${PV}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${CHOST}"
	EOF
	newins env.d ${CHOST}-${PV}

	# nuke the include files, in the end they result in conflicts
	rm -Rf "${ED}/${INCPATH}" || die
}

pkg_postinst() {
	binutils-config ${CHOST}-${PV}
}
