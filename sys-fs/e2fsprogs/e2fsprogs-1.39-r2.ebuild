# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.39-r2.ebuild,v 1.1 2007/03/24 08:52:42 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Standard EXT2 and EXT3 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="nls static"

RDEPEND="~sys-libs/com_err-${PV}
	~sys-libs/ss-${PV}
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-blkid-memleak.patch #171844
	# Fix locale issues while running tests #99766
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch
	epatch "${FILESDIR}"/${PN}-1.38-locale.patch #131462
	# Fix a cosmetic error in mk_cmds's help output.
	epatch "${FILESDIR}"/e2fsprogs-1.32-mk_cmds-cosmetic.patch
	epatch "${FILESDIR}"/e2fsprogs-1.39-util-strptime.patch
	chmod u+w po/*.po # Userpriv fix #27348
	# Clean up makefile to suck less
	epatch "${FILESDIR}"/e2fsprogs-1.39-makefile.patch
	epatch "${FILESDIR}"/e2fsprogs-1.39-parse-types.patch #146903
	# Fixes libintl handling on non-glibc #122368
	epatch "${FILESDIR}"/${PN}-1.39-libintl.patch
	# Fixes sysconfdir being used in prefix correctly
	epatch "${FILESDIR}"/e2fsprogs-1.39-sysconfdir.patch

	# kernel headers use the same defines as e2fsprogs and can cause issues #48829
	sed -i \
		-e 's:CONFIG_JBD_DEBUG:__CONFIG_JBD_DEBUG__E2FS:g' \
		$(grep -rl CONFIG_JBD_DEBUG *) \
		|| die "sed jbd debug failed"

	# fake out files we forked into sep packages
	sed -i \
		-e '/^LIB_SUBDIRS/s:lib/et::' \
		-e '/^LIB_SUBDIRS/s:lib/ss::' \
		Makefile.in || die "remove subdirs"
	ln -s "${EROOT}"/usr/$(get_libdir)/libcom_err.a lib/libcom_err.a
	ln -s "${EROOT}"/$(get_libdir)/libcom_err.so lib/libcom_err.so
	ln -s /usr/bin/mk_cmds lib/ss/mk_cmds
	ln -s "${EROOT}"/usr/include/ss/ss_err.h lib/ss/
	ln -s "${EROOT}"/$(get_libdir)/libss.so lib/libss.so

	# sanity check for Bug 105304
	if [[ -z ${USERLAND} ]] ; then
		eerror "You just hit Bug 105304, please post your 'emerge info' here:"
		eerror "http://bugs.gentoo.org/105304"
		die "Aborting to prevent screwing your system"
	fi
}

src_compile() {
	# Keep the package from doing silly things
	export LDCONFIG="${EPREFIX}"/bin/true
	export CC=$(tc-getCC)
	export STRIP="${EPREFIX}"/bin/true

	econf \
		--bindir="${EPREFIX}"/bin \
		--sbindir="${EPREFIX}"/sbin \
		--enable-elf-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !static dynamic-e2fsck) \
		--without-included-gettext \
		$(use_enable nls) \
		$(use_enable userland_GNU fsck) \
		|| die
	if [[ ${CHOST} != *-uclibc ]] && grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to http://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
	# Parallel make sometimes fails
	emake -j1 COMPILE_ET=compile_et || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog README RELEASE-NOTES SHLIBS
	docinto e2fsck
	dodoc e2fsck/ChangeLog e2fsck/CHANGES

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*.so* "${ED}"/$(get_libdir)/
	dolib.a lib/*.a || die "dolib.a"
	rm -f "${ED}"/usr/$(get_libdir)/libcom_err.a #125146
	local x
	cd "${ED}"/$(get_libdir)
	for x in *.so ; do
		gen_usr_ldscript ${x} || die "gen ldscript ${x}"
	done

	ln -s libext2fs.info.gz  $D/usr/share/info/booga.info.gz
	# move 'useless' stuff to /usr/
	dosbin "${ED}"/sbin/mklost+found
	rm -f "${ED}"/sbin/mklost+found

	# these manpages are already provided by FreeBSD libc
	use elibc_FreeBSD && \
		rm -f "${ED}"/usr/share/man/man3/{uuid,uuid_compare}.3 \
			"${ED}"/usr/share/man/man1/uuidgen.1
}
