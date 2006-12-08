# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-6.7.ebuild,v 1.1 2006/12/08 00:32:10 vapier Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
inherit eutils flag-o-matic toolchain-funcs autotools

PATCH_VER="1.0"
DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="ftp://alpha.gnu.org/gnu/coreutils/${P}.tar.bz2
	mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="acl nls selinux static"
RESTRICT="confcache"

RDEPEND="selinux? ( sys-libs/libselinux )
	acl? ( sys-apps/acl sys-apps/attr )
	nls? ( >=sys-devel/gettext-0.15 )
	!net-mail/base64
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	=sys-devel/automake-1.9*
	>=sys-devel/autoconf-2.59d
	>=sys-devel/m4-1.4-r1
	sys-apps/help2man"

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

	PATCHDIR="${WORKDIR}/patch"
	rm -f "${PATCHDIR}"/generic/001_*progress*

	# Apply the ACL/SELINUX patches.
	if use selinux ; then
		EPATCH_MULTI_MSG="Applying SELINUX patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/selinux
		( cd "${PATCHDIR}" ; epatch selinux/GLUE* ) || die "glue failed"
	else
		EPATCH_MULTI_MSG="Applying ACL patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/acl
	fi

	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/generic
	chmod a+rx tests/sort/sort-mb-tests

	# Since we've patched many .c files, the make process will
	# try to re-build the manpages by running `./bin --help`.
	# When cross-compiling, we can't do that since 'bin' isn't
	# a native binary, so let's just install outdated man-pages.
	tc-is-cross-compiler && touch man/*.1
	# There's no reason for this crap to use the private version
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c

	AT_M4DIR="m4" eautoreconf
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
	else
		myconf="${myconf} --bindir=${EPREFIX}/bin"
	fi

	[[ ${ELIBC} == "glibc" || ${ELIBC} == "uclibc" ]] \
		&& myconf="${myconf} --without-included-regex"

	use static && append-ldflags -static
	econf \
		--enable-largefile \
		$(use_enable nls) \
		$(use_enable acl) \
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
	make install DESTDIR="${D}" || die
	rm -f "${ED}"/usr/lib/charset.alias
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	# remove files provided by other packages
	rm "${ED}"/bin/{kill,uptime} # procps
	rm "${ED}"/bin/{groups,su}   # shadow
	rm "${ED}"/bin/hostname      # net-tools
	rm "${ED}"/usr/share/man/man1/{groups,kill,hostname,su,uptime}.1
	# provide by the man-pages package
	rm "${ED}"/usr/share/man/man1/{chgrp,chmod,chown,cp,dd,df,dir,dircolors}.1
	rm "${ED}"/usr/share/man/man1/{du,install,ln,ls,mkdir,mkfifo,mknod,mv}.1
	rm "${ED}"/usr/share/man/man1/{rm,rmdir,touch,vdir}.1

	insinto /etc
	newins src/dircolors.hin DIR_COLORS

	if [[ ${USERLAND} == "GNU" ]] ; then
		# move non-critical packages into /usr
		cd "${ED}"
		dodir /usr/bin
		mv bin/{csplit,expand,factor,fmt,fold,join,md5sum,nl,od} usr/bin
		mv bin/{paste,pathchk,pinky,pr,printf,sha1sum,shred,sum,tac} usr/bin
		mv bin/{tail,test,[,tsort,unexpand,users} usr/bin
		cd bin
		local x
		for x in * ; do
			dosym /bin/${x} /usr/bin/${x}
		done
	else
		# For now, drop the man pages, collides with the ones of the system.
		rm -rf "${ED}"/usr/share/man
	fi
}
