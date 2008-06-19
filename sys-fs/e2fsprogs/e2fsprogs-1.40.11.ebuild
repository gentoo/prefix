# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.40.11.ebuild,v 1.1 2008/06/18 09:33:56 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Standard EXT2 and EXT3 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls static elibc_FreeBSD"

RDEPEND="~sys-libs/com_err-${PV}
	~sys-libs/ss-${PV}
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch #99766
	chmod u+w po/*.po # Userpriv fix #27348
	# Clean up makefile to suck less
	epatch "${FILESDIR}"/e2fsprogs-1.39-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40.5-libintl.patch #122368
	epatch "${FILESDIR}"/${PN}-1.40-fbsd.patch

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

	# since we've split out com_err/ss into their own ebuilds, we
	# need to fake out the local files.  let the toolchain find them.
	mkdir tc || die
	echo "GROUP ( libcom_err.a )" > tc/libcom_err.a
	echo "GROUP ( libcom_err.so )" > tc/libcom_err.so
	echo "GROUP ( libss.a )" > tc/libss.a
	echo "GROUP ( libss.so )" > tc/libss.so
	sed -i \
		-e '/^LIB\(SS\|COM_ERR\)/s:$(LIB):$(top_builddir)/tc:' \
		MCONFIG.in || die
	echo '#include_next <ss/ss_err.h>' > lib/ss/ss_err.h
	ln -s $(type -P mk_cmds) lib/ss/mk_cmds
	ln -s $(type -P compile_et) lib/et/compile_et

	# sanity check for Bug 105304
	if [[ -z ${USERLAND} ]] ; then
		eerror "You just hit Bug 105304, please post your 'emerge info' here:"
		eerror "http://bugs.gentoo.org/105304"
		die "Aborting to prevent screwing your system"
	fi
}

src_compile() {
	# Keep the package from doing silly things
	addwrite /var/cache/fonts
	export LDCONFIG=:
	export CC=$(tc-getCC)
	export STRIP=:

	econf \
		--bindir="${EPREFIX}"/bin \
		--sbindir="${EPREFIX}"/sbin \
		--enable-elf-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !static dynamic-e2fsck) \
		$(use_enable !elibc_uclibc tls) \
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

	# Build the FreeBSD helper
	if use elibc_FreeBSD ; then
		cp "${FILESDIR}"/fsck_ext2fs.c .
		emake fsck_ext2fs || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README RELEASE-NOTES

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*.so* "${ED}"/$(get_libdir)/
	dolib.a lib/*.a || die "dolib.a"
	rm -f "${ED}"/usr/$(get_libdir)/lib{com_err,ss}.a #125146
	local x
	cd "${ED}"/$(get_libdir)
	for x in *.so ; do
		gen_usr_ldscript ${x} || die "gen ldscript ${x}"
	done

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
