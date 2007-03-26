# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/aspell/aspell-0.60.5.ebuild,v 1.3 2007/03/04 23:30:54 kevquinn Exp $

EAPI="prefix"

# N.B. This is before inherit of autotools, as autotools.eclass adds the
# relevant dependencies to DEPEND.
WANT_AUTOMAKE="1.9"

inherit libtool eutils flag-o-matic autotools

DESCRIPTION="A spell checker replacement for ispell"
HOMEPAGE="http://aspell.net/"
SRC_URI="mirror://gnu/aspell/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="gpm nls"
# Note; app-text/aspell-0.6 and app-dicts/aspell-en-0.6 must go stable together

# Build PDEPEND from list of language codes provided in the tree.
# The PDEPEND string is static - this code just makes it easier to maintain.
def="app-dicts/aspell-en"
for l in \
	"af" "be" "bg" "br" "ca" "cs" "cy" "da" "de" "el" \
	"en" "eo" "es" "et" "fi" "fo" "fr" "ga" "gl" "he" \
	"hr" "is" "it" "nl" "no" "pl" "pt" "ro" "ru" "sk" \
	"sl" "sr" "sv" "uk" "vi"; do
	dep="linguas_${l}? ( app-dicts/aspell-${l} )"
#	[[ -z ${PDEPEND} ]] &&
#		PDEPEND="${dep}" ||
#		PDEPEND="${PDEPEND}
#${dep}"
	def="!linguas_${l}? ( ${def} )"
done
PDEPEND="${PDEPEND}
${def}"

RDEPEND=">=sys-libs/ncurses-5.2
	gpm? ( sys-libs/gpm )
	nls? ( virtual/libintl )"
# English dictionary 0.5 is incompatible with aspell-0.6

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/aspell-0.60.3-templateinstantiations.patch
	epatch "${FILESDIR}/${P}-nls.patch"

	eautomake
	elibtoolize --reverse-deps
}

src_compile() {
	use gpm && append-ldflags -lgpm
	filter-flags -fno-rtti
	filter-flags -fvisibility=hidden #77109
	filter-flags -maltivec -mabi=altivec
	use ppc && append-flags -mno-altivec

	econf \
		$(use_enable nls) \
		--disable-static \
		--sysconfdir="${EPREFIX}"/etc/aspell \
		--enable-docdir="${EPREFIX}"/usr/share/doc/${PF} || die

	emake || die
}

src_install() {
	dodoc README* TODO

	make DESTDIR="${D}" install || die
	mv "${ED}"/usr/share/doc/${PF}/man-html "${ED}"/usr/share/doc/${PF}/html
	mv "${ED}"/usr/share/doc/${PF}/man-text "${ED}"/usr/share/doc/${PF}/text

	# install ispell/aspell compatibility scripts
	exeinto /usr/bin
	newexe scripts/ispell ispell-aspell
	newexe scripts/spell spell-aspell

	cd examples
	make clean || die
	docinto examples
	dodoc ${S}/examples/*
}

pkg_postinst() {
	elog "You will need to install a dictionary now.  Please choose an"
	elog "aspell-<LANG> dictionary from the app-dicts category"
	elog "After installing an aspell dictionary for your language(s),"
	elog "You may use the aspell-import utility to import your personal"
	elog "dictionaries from ispell, pspell and the older aspell"

	ewarn ""
	ewarn "Please re-emerge ALL your aspell-LANG dictionaries"
	ewarn ""
	ebeep 5
}
