# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-6.9-r1.ebuild,v 1.19 2008/02/23 04:15:50 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs autotools

PATCH_VER="1.3"
DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="ftp://alpha.gnu.org/gnu/coreutils/${P}.tar.bz2
	mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl nls selinux static xattr"

RDEPEND="selinux? ( sys-libs/libselinux )
	acl? ( sys-apps/acl )
	xattr? ( sys-apps/attr )
	nls? ( >=sys-devel/gettext-0.15 )
	!net-mail/base64
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	>=sys-devel/automake-1.10
	>=sys-devel/autoconf-2.61
	>=sys-devel/m4-1.4-r1"

pkg_setup() {
	# fixup expr for #123342 (rely on path)
	if [[ $(expr a : '\(a\)') != "a" ]] ; then
		if [[ -x ${EPREFIX}/bin/busybox ]] ; then
			ln -sf ${EPREFIX}/bin/busybox ${EPREFIX}/bin/expr
		else
			eerror "Your expr binary appears to be broken, please fix it."
			eerror "For more info, see http://bugs.gentoo.org/123342"
			die "your expr is broke"
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/gnulib-futimens-rename.patch #180764
	sed -i 's:\<futimens\>:gl_futimens:' src/{copy,touch}.c

	PATCHDIR="${WORKDIR}/patch"
	rm -f "${PATCHDIR}"/generic/001_*progress*

	# Apply the ACL/SELINUX patches.
	if use selinux ; then
		EPATCH_MULTI_MSG="Applying SELINUX patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/selinux
	else
		EPATCH_MULTI_MSG="Applying ACL patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/acl
	fi

	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/generic
	epatch "${FILESDIR}"/${PV}-iswblank.patch

	# interix lacks ESTALE
	epatch "${FILESDIR}"/${PV}-interix.patch

	# no need to abort when unable to 'list mounted fs'
	epatch "${FILESDIR}"/${PV}-without-mountfs.patch

	chmod a+rx tests/sort/sort-mb-tests
	chmod a+rx tests/ls/x-option

	# Since we've patched many .c files, the make process will try to
	# re-build the manpages by running `./bin --help`.  When doing a
	# cross-compile, we can't do that since 'bin' isn't a native bin.
	# Also, it's not like we changed the usage on any of these things,
	# so let's just update the timestamps and skip the help2man step.
	touch man/*.1
	# There's no reason for this crap to use the private version
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c

	AT_M4DIR="m4" eautoreconf

	# For platforms which don't have /usr/bin/perl (like FreeBSD) make sure we
	# don't regenerate wheel.h after above patches
	touch src/wheel.h
}

src_compile() {

	if ! type -p cvs > /dev/null ; then
		# Fix issues with gettext's autopoint if cvs is not installed,
		# bug #28920.
		export AUTOPOINT="${EPREFIX}/bin/true"
	fi

	local myconf=""
	# put stuff in usr/libexec/gnu for x86-fbsd, if non-prefixed
	if [[ ${EPREFIX%/} == "" ]] && [[ ${USERLAND} != "GNU" ]]; then
		myconf="${myconf} --bindir=${EPREFIX}/usr/libexec/gnu"
	fi

	# somehow this works for spanky/spanky thinks this works
#	if echo "#include <regex.h>" | $(tc-getCPP) > /dev/null ; then
#		myconf="${myconf} --without-included-regex"
#	fi
	# it doesn't for Linux and Darwin, so we do it the oldfashioned way
	[[ ${ELIBC} == "glibc" || ${ELIBC} == "uclibc" ]] \
		&& myconf="${myconf} --without-included-regex"

	[[ ${CHOST} == *-darwin9 ]] && append-flags -D__DARWIN_UNIX03=0

	# cross-compile workaround #177061
	[[ ${CHOST} == *-linux* ]] && export fu_cv_sys_stat_statvfs=yes

	if [[ ${CHOST} == *-interix* ]]; then
		# work around broken headers
		export ac_cv_header_inttypes_h=no
		export ac_cv_header_stdint_h=no
		export gl_cv_header_inttypes_h=no
		export gl_cv_header_stdint_h=no
		append-flags "-Dgetgrgid=getgrgid_nomembers"
	fi

	use static && append-ldflags -static
	econf \
		--enable-largefile \
		$(use_enable nls) \
		$(use_enable acl) \
		$(use_enable xattr) \
		$(use_enable selinux) \
		${myconf} \
		|| die "econf"
	emake || die "emake"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"
	addwrite /dev/full
	export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	make check || die "make check failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	rm -f "${ED}"/usr/lib/charset.alias
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	# remove files provided by other packages
	rm -f "${ED}"/usr/bin/{kill,uptime} # procps
	rm -f "${ED}"/usr/bin/{groups,su}   # shadow
	rm -f "${ED}"/usr/bin/hostname      # net-tools
	rm -f "${ED}"/usr/share/man/man1/{groups,kill,hostname,su,uptime}.1

	insinto /etc
	newins src/dircolors.hin DIR_COLORS

	if [[ ${USERLAND} == "GNU" || ${EPREFIX%/} != "" ]] ; then
		cd "${ED}"/usr/bin
		dodir /bin
		# move critical binaries into /bin (required by FHS)
		local fhs="cat chgrp chmod chown cp date dd echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"

		# on interix "df" is not built, since there are no means of
		# getting a list of mounted filesystems.
		[[ ${CHOST} != *-interix* ]] && fhs="${fhs} df"

		mv ${fhs} ../../bin/ || die "could not move fhs bins"
		# move critical binaries into /bin (common scripts)
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "could not move common bins"
		# create a symlink for uname in /usr/bin/ since autotools require it
		local x
		for x in ${com} uname ; do
			dosym /bin/${x} /usr/bin/${x} || die
		done
	else
		# For now, drop the man pages, collides with the ones of the system.
		rm -rf "${ED}"/usr/share/man
	fi
}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells."
}
