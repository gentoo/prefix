# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sed/sed-4.1.4.ebuild,v 1.11 2005/08/09 17:44:01 flameeyes Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"
SRC_URI="mirror://gnu/sed/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha arm amd64 hppa ia64 m68k mips ppc ppc64 ppc-macos s390 sh sparc x86"
IUSE="nls static build bootstrap"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_bootstrap_sed() {
	# make sure system-sed works #40786
	export NO_SYS_SED=""
	#if ! use bootstrap && ! use build ; then
		if ! type -p sed ; then
			NO_SYS_SED="!!!"
			./bootstrap.sh || die "couldnt bootstrap"
			cp sed/sed ${T}/ || die "couldnt copy"
			export PATH="${PATH}:${T}"
		fi
	#fi
}
src_bootstrap_cleanup() {
	if [[ -n ${NO_SYS_SED} ]] ; then
		make clean || die "couldnt clean"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-makeinfo-c-locale.patch
	epatch "${FILESDIR}"/${P}-fix-invalid-ref-error.patch
	sed -i \
		-e "/docdir =/s:/doc:/doc/${PF}/html:" \
		doc/Makefile.in || die "sed html doc"
}

src_compile() {
	src_bootstrap_sed

	local myconf=""
	if ! use userland_GNU; then
		myconf="--program-prefix=g"
	fi
	econf \
		$(use_enable nls) \
		${myconf} \
		|| die "Configure failed"

	src_bootstrap_cleanup
	use static && append-ldflags -static
	emake LDFLAGS="${LDFLAGS}" || die "build failed"
}

src_install() {
	into /
	#if ! use userland_GNU; then
	#	newbin sed/sed gsed || die "dobin"
	#else
		dobin sed/sed || die "dobin"
	#fi

	if ! use build ; then
		make install DESTDIR="${DEST}" || die "Install failed"
		dodoc NEWS README* THANKS AUTHORS BUGS ChangeLog
		docinto examples
		dodoc "${FILESDIR}/dos2unix" "${FILESDIR}/unix2dos"
	else
		dodir /usr/bin
	fi

	if ! use userland_GNU; then
		cd "${D}"
		rm -f "${D}"/usr/bin/gsed
		dosym /bin/gsed /usr/bin/gsed
		rm "${D}"/usr/lib/charset.alias "${D}"/usr/share/locale/locale.alias
	else
		rm -f "${D}"/usr/bin/sed
		dosym /bin/sed /usr/bin/sed
	fi
}
