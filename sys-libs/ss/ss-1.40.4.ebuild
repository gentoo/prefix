# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ss/ss-1.40.4.ebuild,v 1.7 2008/03/16 08:37:06 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Subsystem command parsing library"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/e2fsprogs-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls"

RDEPEND="~sys-libs/com_err-${PV}"
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
	epatch "${FILESDIR}"/${PN}-1.40.4-check.patch #201762
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
	ln -s $(${CC} -print-file-name=libcom_err${lib}) lib/libcom_err${lib}
	emake -j1 -C lib/ss check || die "make check failed"
}

src_install() {
	env_setup

	dodir /usr/share/man/man1
	make -C lib/ss DESTDIR="${D}" install || die

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*$(get_libname)* "${ED}"/$(get_libdir)/ || die "move .so"
	dolib.a lib/libss.a || die "dolib.a"
	gen_usr_ldscript libss$(get_libname)
}
