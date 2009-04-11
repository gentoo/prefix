# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ss/ss-1.40.8.ebuild,v 1.8 2008/08/26 18:45:44 gentoofan23 Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Subsystem command parsing library"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/e2fsprogs-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="nls"

RDEPEND="~sys-libs/com_err-${PV}
	!sys-libs/e2fsprogs-libs"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/e2fsprogs-${PV}

env_setup() {
	export LDCONFIG="${EPREFIX}"/bin/true
	export CC=$(tc-getCC)
	export STRIP="${EPREFIX}"/bin/true
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.39-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40.5-darwin-makefile.patch

	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-*bsd*)
	# since we've split out com_err/ss into their own ebuilds, we
	# need to fake out the local files.  let the toolchain find them.
	echo "GROUP ( ${EPREFIX}/usr/$(get_libdir)/libcom_err.a )" > lib/libcom_err.a
	echo "GROUP ( ${EPREFIX}/usr/$(get_libdir)/libcom_err.so )" > lib/libcom_err.so
		;;
	esac
}

src_compile() {
	env_setup

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	econf \
		--enable-${libtype}-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable nls) \
		|| die
	emake -C lib/ss COMPILE_ET=compile_et || die "make ss failed"
}

src_test() {
	env_setup

	local lib=$(get_libname)
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-*bsd*)
			: # this is the same as the case in src_unpack
		;;
		*)
			ln -s $(${CC} -print-file-name=libcom_err${lib}) lib/libcom_err${lib}
		;;
	esac
	emake -j1 -C lib/ss check || die "make check failed"
}

src_install() {
	env_setup

	dodir /usr/share/man/man1
	emake -C lib/ss DESTDIR="${D}" install || die

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*$(get_libname)* "${ED}"/$(get_libdir)/ || die "move .so"
	dolib.a lib/libss.a || die "dolib.a"
	gen_usr_ldscript libss$(get_libname)
}
