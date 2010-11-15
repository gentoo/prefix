# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.23-r4.ebuild,v 1.1 2010/07/19 21:52:44 vapier Exp $

EAPI="3"

inherit flag-o-matic

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRC_URI="http://ftp.gnu.org/gnu/tar/${P}.tar.bz2
	ftp://alpha.gnu.org/gnu/tar/${P}.tar.bz2
	mirror://gnu/tar/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static userland_GNU"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_prepare() {
	# somehow, on interix 6, tar detects changing files/dirs
	# all the time, although nothing is happening on the fs.
	# probably a bug in stat()...
	[[ ${CHOST} == *-interix6* ]] && \
		epatch "${FILESDIR}"/${PN}-1.22-interix-change.patch

	epatch "${FILESDIR}"/${P}-revert-pipe.patch #309001
	epatch "${FILESDIR}"/${P}-strncpy.patch #317139
	epatch "${FILESDIR}"/${P}-symlink-k-hang.patch #327641
	epatch "${FILESDIR}"/${P}-tests.patch #326785

	if ! use userland_GNU ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi
}

src_configure() {
	local myconf
	# hack around ld: duplicate symbol _argp_fmtstream_putc problem
	[[ ${CHOST} == *-darwin* ]] && append-flags -U__OPTIMIZE__
	use static && append-ldflags -static
	use userland_GNU || myconf="--program-prefix=g"
	# Work around bug in sandbox #67051
	gl_cv_func_chown_follows_symlink=yes \
	econf \
		--enable-backup-scripts \
		--bindir="${EPREFIX}"/bin \
		--libexecdir="${EPREFIX}"/usr/sbin \
		$(use_enable nls) \
		${myconf}
}

src_install() {
	local p=""
	use userland_GNU || p=g

	emake DESTDIR="${D}" install || die "make install failed"

	if [[ -z ${p} ]] ; then
		# a nasty yet required piece of baggage
		exeinto /etc
		doexe "${FILESDIR}"/rmt || die
	fi

	# autoconf looks for gtar before tar (in configure scripts), hence
	# in Prefix it is important that it is there, otherwise, a gtar from
	# the host system (FreeBSD, Solaris, Darwin) will be found instead
	# of the Prefix provided (GNU) tar
	if use prefix ; then
		dodir /usr/bin
		dosym /bin/tar /usr/bin/gtar
	fi

	dodoc AUTHORS ChangeLog* NEWS README* THANKS
	newman "${FILESDIR}"/tar.1 ${p}tar.1
	mv "${ED}"/usr/sbin/${p}backup{,-tar}
	mv "${ED}"/usr/sbin/${p}restore{,-tar}
}
