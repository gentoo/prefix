# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.16.1.ebuild,v 1.11 2007/04/07 14:53:34 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRC_URI="http://ftp.gnu.org/gnu/tar/${P}.tar.bz2
	ftp://alpha.gnu.org/gnu/tar/${P}.tar.bz2
	mirror://gnu/tar/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="nls static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/tar-1.16-darwin.patch
	if [[ ${USERLAND} != "GNU" ]] && [[ ${EPREFIX%/} == "" ]] ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi
}

src_compile() {
	local myconf
	use static && append-ldflags -static
	[[ ${USERLAND} != "GNU" ]] && [[ ${EPREFIX%/} == "" ]] && \
		myconf="--program-prefix=g"
	# Work around bug in sandbox #67051
	gl_cv_func_chown_follows_symlink=yes \
	econf \
		--enable-backup-scripts \
		$(with_bindir) \
		--libexecdir=${EPREFIX}/usr/sbin \
		$(use_enable nls) \
		${myconf} || die
	emake || die "emake failed"
}

src_install() {
	local p=""
	use userland_GNU || [[ ${EPREFIX%/} != "" ]] || p=g

	emake DESTDIR="${D}" install || die "make install failed"

	if [[ -z ${p} ]] ; then
		# a nasty yet required piece of baggage
		exeinto /etc
		doexe "${FILESDIR}"/rmt || die
	fi

	dodoc AUTHORS ChangeLog* NEWS README* PORTS THANKS
	newman "${FILESDIR}"/tar.1 ${p}tar.1
	mv "${ED}"/usr/sbin/${p}backup{,-tar}
	mv "${ED}"/usr/sbin/${p}restore{,-tar}

	rm -f "${ED}"/usr/$(get_libdir)/charset.alias
}
