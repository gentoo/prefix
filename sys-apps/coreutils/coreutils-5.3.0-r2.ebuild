# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-5.3.0-r2.ebuild,v 1.1 2005/10/05 00:19:35 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

PATCH_VER=1.4

DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~seemant/distfiles/${P}-patches-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="acl build nls selinux static"

RDEPEND="selinux? ( sys-libs/libselinux )
	acl? ( sys-apps/acl sys-apps/attr )
	nls? ( sys-devel/gettext )
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	>=sys-apps/portage-2.0.49
	=sys-devel/automake-1.8*
	>=sys-devel/autoconf-2.58
	>=sys-devel/m4-1.4-r1
	!elibc_uclibc? ( sys-apps/help2man )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	PATCHDIR="${WORKDIR}/patch"

	EPATCH_MULTI_MSG="Applying patches from Mandrake ..." \
	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/mandrake

	# Apply the ACL/SELINUX patches.
	if use selinux ; then
		EPATCH_MULTI_MSG="Applying SELINUX patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/selinux
		( cd "${PATCHDIR}" ; epatch selinux/GLUE* ) || die "glue failed"
	elif use acl ; then
		EPATCH_MULTI_MSG="Applying ACL patches ..." \
		EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/acl
	fi

	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/generic
	EPATCH_SUFFIX="patch" epatch "${PATCHDIR}"/extra

	# Since we've patched many .c files, the make process will 
	# try to re-build the manpages by running `./bin --help`.  
	# When cross-compiling, we can't do that since 'bin' isn't 
	# a native binary, so let's just install outdated man-pages.
	tc-is-cross-compiler && touch man/*.1

	ebegin "Reconfiguring configure scripts (be patient)"
	export WANT_AUTOMAKE=1.8
	export WANT_AUTOCONF=2.5
	aclocal -I m4 || die "aclocal"
	autoconf || die "autoconf"
	automake || die "automake"
	eend $?
}

src_compile() {
	if ! type -p cvs > /dev/null ; then
		# Fix issues with gettext's autopoint if cvs is not installed,
		# bug #28920.
		export AUTOPOINT="/bin/true"
	fi

	local myconf=""
	[[ ${USERLAND} == "GNU" ]] \
		&& myconf="${myconf} $(with_bindir)"
		
	[[ ${USERLAND} == "BSD" ]] \
		&& myconf="${myconf} --program-prefix=g"

	econf \
		--enable-largefile \
		$(use_enable nls) \
		$(use_enable selinux) \
		${myconf} \
		|| die "econf"

	use static && append-ldflags -static
	emake LDFLAGS="${LDFLAGS}" || die "emake"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod a+rx "${WORKDIR}"
	addwrite /dev/full
	export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	make check || die "make check failed"
}

src_install() {
	make install DESTDIR="${DEST}" || die
	rm -f "${D}"/usr/lib/charset.alias

	# remove files provided by other packages
	rm "${D}"/bin/{kill,uptime} # procps
	rm "${D}"/bin/{groups,su}   # shadow
	rm "${D}"/bin/hostname      # net-tools
	rm "${D}"/usr/share/man/man1/{groups,kill,hostname,su,uptime}.1
	# provide by the man-pages package
	rm "${D}"/usr/share/man/man1/{chgrp,chmod,chown,cp,dd,df,dir,dircolors}.1
	rm "${D}"/usr/share/man/man1/{du,install,ln,ls,mkdir,mkfifo,mknod,mv}.1
	rm "${D}"/usr/share/man/man1/{rm,rmdir,touch,vdir}.1

	insinto /etc
	doins "${FILESDIR}"/DIR_COLORS

	if [[ ${USERLAND} == "GNU" ]] ; then
		# move non-critical packages into /usr
		cd "${D}"
		dodir /usr/bin
		mv bin/{csplit,expand,factor,fmt,fold,join,md5sum,nl,od} usr/bin
		mv bin/{paste,pathchk,pinky,pr,printf,sha1sum,shred,sum,tac} usr/bin
		mv bin/{tail,test,[,tsort,unexpand,users} usr/bin
		cd bin
		local x
		for x in * ; do
			dosym /bin/${x} /usr/bin/${x}
		done
	fi

	if ! use build ; then
		cd "${S}"
		dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO
	else
		rm -r "${D}"/usr/share
	fi
}
