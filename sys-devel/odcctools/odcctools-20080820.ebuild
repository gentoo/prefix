# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils

DESCRIPTION="Darwin assembler as(1) and static linker ld(1), Xcode Tools 3.1"
HOMEPAGE="http://trac.macosforge.org/projects/odcctools"
SRC_URI="http://www.gentoo.org/~grobian/distfiles/${P}.tar.bz2"

LICENSE="APSL-2"

KEYWORDS="~ppc-macos ~x86-macos ~x86-solaris"

IUSE=""

DEPEND="sys-devel/binutils-config"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

# Magic from toolchain-binutils.eclass
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

if is_cross ; then
	SLOT="${CTARGET}"
else
	SLOT="0"
fi

LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${PV}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${PV}
if is_cross ; then
	BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${PV}
else
	BINPATH=/usr/${CTARGET}/binutils-bin/${PV}
fi

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [[ ${CHOST} != *-apple-darwin* ]] ; then
		# this patch should still allow for compilation on Darwin, but I don't
		# want of run the risk of breaking something, so I make sure it stays
		# vanilla on Darwin
#		epatch "${FILESDIR}"/${P}-solaris.patch

		# ld64 depends on Darwin kernel headers, so its unlikely this can/will
		# compile
#		sed -i -e '/^COMPONENTS=/s/ld64//' configure
:
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
		--includedir=${EPREFIX}${INCPATH} \
		--program-prefix="
	is_cross && myconf="${myconf} --with-sysroot=${EPREFIX}/usr/${CTARGET}"
	echo -e "./configure ${myconf//--/\n\t--}"
	./configure ${myconf} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die

	# nuke the include files, in the end they result in conflicts
	rm -Rf "${ED}/${INCPATH}" || die

	mv "${ED}"${BINPATH}/ld64 "${ED}"${BINPATH}/ld
	dosym ld ${BINPATH}/ld64

	# Now we collect everything into the proper SLOT-ed dirs
	# When something is built to cross-compile, it installs into
	# /usr/$CHOST/ by default ... we have to 'fix' that :)
	if is_cross ; then
		cd "${ED}"/${BINPATH}
		for x in * ; do
			mv ${x} ${x/${CTARGET}-}
		done

		if [[ -d ${ED}/usr/${CHOST}/${CTARGET} ]] ; then
			mv "${ED}"/usr/${CHOST}/${CTARGET}/include "${ED}"/${INCPATH}
			mv "${ED}"/usr/${CHOST}/${CTARGET}/lib/* "${ED}"/${LIBPATH}/
			rm -r "${ED}"/usr/${CHOST}/{include,lib}
		fi
	fi

	# Generate an env.d entry for this binutils
	cd "${S}"
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
		TARGET="${CTARGET}"
		VER="${PV}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${CTARGET}"
	EOF
	newins env.d ${CTARGET}-${PV}
}

pkg_postinst() {
	binutils-config ${CTARGET}-${PV}
}
