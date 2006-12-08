# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.16-r2.ebuild,v 1.9 2006/12/06 21:34:52 eroyf Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRC_URI="http://ftp.gnu.org/gnu/tar/${P}.tar.bz2
	ftp://alpha.gnu.org/gnu/tar/${P}.tar.bz2
	mirror://gnu/tar/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-darwin.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-segv.patch
	epatch "${FILESDIR}"/${P}-remove-GNUTYPE_NAMES.patch #155901
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

	# a nasty yet required symlink
	dodir /etc
	dosym /usr/sbin/${p}rmt /etc/${p}rmt

	dodoc AUTHORS ChangeLog* NEWS README* PORTS THANKS
	newman "${FILESDIR}"/tar.1 ${p}tar.1
	mv "${ED}"/usr/sbin/${p}backup{,-tar}
	mv "${ED}"/usr/sbin/${p}restore{,-tar}

	rm -f "${ED}"/usr/$(get_libdir)/charset.alias
}
