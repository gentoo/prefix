# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="https://www.gnu.org/software/help2man/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

# Needed to rebase the Makefile hunk, now in files/
#CYGWIN_PATCHREV="60ae068c5e01fbed4ee3f86107f7df64d596a864"
#CYGWIN_PATCH="1.40.4-cygwin-nls.patch"
#SRC_URI+=" elibc_Cygwin? (
#	https://raw.githubusercontent.com/cygwinports/help2man/${CYGWIN_PATCHREV}/${CYGWIN_PATCH} -> ${PN}-${CYGWIN_PATCH}
#)"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

RDEPEND="dev-lang/perl
	nls? ( dev-perl/Locale-gettext )"
DEPEND="${RDEPEND}"

DOCS=( debian/changelog NEWS README THANKS ) #385753

PATCHES=(
	"${FILESDIR}"/${PN}-1.46.1-linguas.patch
)

src_prepare() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i \
			-e 's/-shared/-bundle/' \
			Makefile.in || die
	fi

	default

	use elibc_Cygwin && eapply -p2 "${FILESDIR}"/${PN}-1.47.16-cygwin.patch
}

src_configure() {
	# Disable gettext requirement as the release includes the gmo files #555018
	local myeconfargs=(
		ac_cv_path_MSGFMT=$(type -P false)
		$(use_enable nls)
	)
	econf "${myeconfargs[@]}"
}
