# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/nano/nano-2.0.3.ebuild,v 1.1 2007/01/29 16:30:05 vapier Exp $

EAPI="prefix"

#ECVS_SERVER="savannah.gnu.org:/cvsroot/nano"
#ECVS_MODULE="nano"
#ECVS_AUTH="pserver"
#ECVS_USER="anonymous"
#inherit cvs

MY_P=${PN}-${PV/_}
DESCRIPTION="GNU GPL'd Pico clone with more functionality"
HOMEPAGE="http://www.nano-editor.org/"
SRC_URI="http://www.nano-editor.org/dist/v${PV:0:3}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="debug justify minimal ncurses nls slang spell unicode"

DEPEND=">=sys-libs/ncurses-5.2
	nls? ( sys-devel/gettext )
	!ncurses? ( slang? ( sys-libs/slang ) )"
PROVIDE="virtual/editor"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [[ ! -e configure ]] ; then
		./autogen.sh || die "autogen failed"
	fi
}

src_compile() {
	local myconf=""
	use ncurses \
		&& myconf="--without-slang" \
		|| myconf="${myconf} $(use_with slang)"

	econf \
		--bindir="${EPREFIX}"/bin \
		--enable-color \
		--enable-multibuffer \
		--enable-nanorc \
		--disable-wrapping-as-root \
		$(use_enable spell) \
		$(use_enable justify) \
		$(use_enable debug) \
		$(use_enable nls) \
		$(use_enable unicode utf8) \
		$(use_enable minimal tiny) \
		${myconf} \
		|| die "configure failed"
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc ChangeLog README doc/nanorc.sample AUTHORS BUGS NEWS TODO
	dohtml *.html
	insinto /etc
	newins doc/nanorc.sample nanorc

	insinto /usr/share/nano
	doins "${FILESDIR}"/*.nanorc || die
	echo $'\n''# include "'"${EPREFIX}"'/usr/share/nano/gentoo.nanorc"' >> "${ED}"/etc/nanorc

	dodir /usr/bin
	dosym /bin/nano /usr/bin/nano
}

pkg_postinst() {
	elog "More helpful info about nano, visit the GDP page:"
	elog "http://www.gentoo.org/doc/en/nano-basics-guide.xml"
}
