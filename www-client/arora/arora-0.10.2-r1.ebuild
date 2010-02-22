# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/arora/arora-0.10.2-r1.ebuild,v 1.3 2010/02/17 21:13:59 wired Exp $

EAPI=2
inherit eutils qt4

DESCRIPTION="A cross-platform Qt4 WebKit browser"
HOMEPAGE="http://arora.googlecode.com/"
SRC_URI="http://arora.googlecode.com/files/${P}.tar.gz"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="debug doc"

RDEPEND="x11-libs/qt-gui
	x11-libs/qt-sql
	x11-libs/qt-webkit
	x11-libs/qt-xmlpatterns"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

ARORA_LANGS="ast ca es es_CR et_EE fr_CA gl ms nb_NO pt_BR pt_PT sr@latin sr_CS uk
zh_CN zh_TW"
ARORA_NOLONGLANGS="cs_CZ da_DK de_DE el_GR fi_FI fr_FR he_IL hu_HU it_IT ja_JP
nl_NL pl_PL ru_RU sk_SK tr_TR"

for L in $ARORA_LANGS; do
	IUSE="$IUSE linguas_$L"
done
for L in $ARORA_NOLONGLANGS; do
	IUSE="$IUSE linguas_${L%_*}"
done

src_prepare() {
	# use Gentoo lingua designations
	mv src/locale/sr_RS@latin.ts src/locale/sr@latin.ts
	mv src/locale/sr_RS.ts src/locale/sr_CS.ts

	# process linguas
	local langs=
	for lingua in $LINGUAS; do
		if has $lingua $ARORA_LANGS; then
			langs="$langs ${lingua}.ts"
		else
			for a in $ARORA_NOLONGLANGS; do
				if [[ $lingua == ${a%_*} ]]; then
					langs="$langs ${a}.ts"
				fi
			done
		fi
	done

	# remove all translations, then add only the ones we want
	sed -i '/ts/d' src/locale/locale.pri || die 'sed failed'
	sed -i "/^TRANSLATIONS/s:\\\:${langs}:" src/locale/locale.pri \
		|| die 'sed failed'

	if ! use doc ; then
		sed -i 's|QMAKE_EXTRA|#QMAKE_EXTRA|' arora.pro || die 'sed failed'
	fi
}

src_configure() {
	eqmake4 arora.pro PREFIX="${EPREFIX}"/usr
}

src_compile() {
	emake || die "make failed"

	# don't pre-strip
	sed -i "/strip/d" src/Makefile || die 'sed failed'
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die 'make install failed'
	dodoc AUTHORS ChangeLog README
}
