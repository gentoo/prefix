# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.23.ebuild,v 1.1 2010/03/10 13:55:50 vapier Exp $

inherit flag-o-matic eutils prefix

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRC_URI="http://ftp.gnu.org/gnu/tar/${P}.tar.bz2
	ftp://alpha.gnu.org/gnu/tar/${P}.tar.bz2
	mirror://gnu/tar/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

#	epatch "${FILESDIR}"/${PN}-1.16-darwin.patch

	# somehow, on interix 6, tar detects changing files/dirs
	# all the time, although nothing is happening on the fs.
	# probably a bug in stat()...
	[[ ${CHOST} == *-interix6* ]] && \
		epatch "${FILESDIR}"/${PN}-1.22-interix-change.patch

	if ! use userland_GNU ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi
	cd "${T}"
	cp "${FILESDIR}"/rmt "${T}"
	epatch "${FILESDIR}"/rmt-prefix.patch
	eprefixify rmt
}

src_compile() {
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
		${myconf} || die
	emake || die "emake failed"
}

src_install() {
	local p=""
	use userland_GNU || p=g

	emake DESTDIR="${D}" install || die "make install failed"

	if [[ -z ${p} ]] ; then
		# a nasty yet required piece of baggage
		exeinto /etc
		doexe "${T}"/rmt || die
	fi

	# autoconf looks for this, so in prefix, make sure it is there
	if use prefix ; then
		dodir /usr/bin
		dosym /bin/tar /usr/bin/gtar
	fi

	dodoc AUTHORS ChangeLog* NEWS README* THANKS
	newman "${FILESDIR}"/tar.1 ${p}tar.1
	mv "${ED}"/usr/sbin/${p}backup{,-tar}
	mv "${ED}"/usr/sbin/${p}restore{,-tar}

	rm -f "${ED}"/usr/$(get_libdir)/charset.alias
}
