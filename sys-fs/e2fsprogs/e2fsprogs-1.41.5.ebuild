# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.41.5.ebuild,v 1.1 2009/05/29 23:27:02 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Standard EXT2 and EXT3 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls elibc_FreeBSD"

RDEPEND="~sys-libs/${PN}-libs-${PV}
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-apps/texinfo"

pkg_setup() {
	if [[ ! -e ${EROOT}/etc/mtab ]] ; then
		# add some crap to deal with missing /etc/mtab #217719
		ewarn "No /etc/mtab file, creating one temporarily"
		echo "${PN} crap for src_test" > "${EROOT}"/etc/mtab
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch #99766
	epatch "${FILESDIR}"/${PN}-1.41.5-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40-fbsd.patch
	epatch "${FILESDIR}"/${PN}-1.41.1-darwin-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.41.4-darwin-no-mntent.patch
	# blargh ... trick e2fsprogs into using e2fsprogs-libs
	rm -rf doc
	sed -i -r \
		-e 's:@LIBINTL@:@LTLIBINTL@:' \
		-e '/^LIB(COM_ERR|SS|UUID)/s:[$][(]LIB[)]/lib([^@]*)@LIB_EXT@:-l\1:' \
		-e '/^DEPLIB(COM_ERR|SS|UUID)/s:=.*:=:' \
		MCONFIG.in || die "muck libs" #122368
	sed -i -r \
		-e '/^LIB_SUBDIRS/s:lib/(et|ss|uuid)::g' \
		Makefile.in || die "remove subdirs"
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure
	touch lib/ss/ss_err.h
}

src_compile() {
	# Keep the package from doing silly things
	addwrite /var/cache/fonts

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	# On MacOSX 10.4 using the assembly built-in bitoperation functions causes
	# segmentation faults. Though this is likely fixable we can quickly make it
	# at least work by using the C functions.
	if [[ ${CHOST} == i?86-apple-darwin* ]]; then
		append-flags -D_EXT2_USE_C_VERSIONS_
	fi

	ac_cv_path_LDCONFIG=: \
	econf \
		--bindir="${EPREFIX}"/bin \
		--sbindir="${EPREFIX}"/sbin \
		--enable-${libtype}-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !elibc_uclibc tls) \
		--without-included-gettext \
		$(use_enable nls) \
		$(use_enable userland_GNU fsck) \
		--disable-libblkid \
		|| die
	if [[ ${CHOST} != *-uclibc ]] && grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to http://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
	# MKDIR pic is done too late
	emake -j1 COMPILE_ET=compile_et MK_CMDS=mk_cmds || die

	# Build the FreeBSD helper
	if use elibc_FreeBSD ; then
		cp "${FILESDIR}"/fsck_ext2fs.c .
		emake fsck_ext2fs || die
	fi
}

pkg_preinst() {
	if [[ -r ${EROOT}/etc/mtab ]] ; then
		if [[ $(<"${EROOT}"/etc/mtab) == "${PN} crap for src_test" ]] ; then
			rm -f "${EROOT}"/etc/mtab
		fi
	fi
}

src_install() {
	emake STRIP=: DESTDIR="${D}" install install-libs || die
	dodoc README RELEASE-NOTES

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	set -- "${ED}"/usr/$(get_libdir)/*.a
	set -- ${@/*\/lib}
	gen_usr_ldscript -a "${@/.a}"

	# move 'useless' stuff to /usr/
	dosbin "${ED}"/sbin/mklost+found
	rm -f "${ED}"/sbin/mklost+found

	if use elibc_FreeBSD ; then
		# Install helpers for us
		into /
		dosbin "${S}"/fsck_ext2fs || die
		doman "${FILESDIR}"/fsck_ext2fs.8

		# these manpages are already provided by FreeBSD libc
		# and filefrag is linux only
		rm -f \
			"${ED}"/sbin/filefrag \
			"${ED}"/usr/share/man/man8/filefrag.8 \
			"${ED}"/bin/uuidgen \
			"${ED}"/usr/share/man/man3/{uuid,uuid_compare}.3 \
			"${ED}"/usr/share/man/man1/uuidgen.1 || die
	fi
}
