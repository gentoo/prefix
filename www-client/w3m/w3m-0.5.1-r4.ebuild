# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/w3m/w3m-0.5.1-r4.ebuild,v 1.8 2007/01/10 20:26:34 malc Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Text based WWW browser, supports tables and frames"
HOMEPAGE="http://w3m.sourceforge.net/
	http://www.page.sannet.ne.jp/knabe/w3m/w3m.html"
PATCH_PATH="http://www.page.sannet.ne.jp/knabe/w3m/"
SRC_URI="mirror://sourceforge/w3m/${P}.tar.gz
	async? ( ${PATCH_PATH}/w3m-cvs-1.942-async-7.diff.gz )
	http://dev.gentoo.org/~usata/distfiles/${P}-cvs1.938.diff.gz"
# w3m color patch:
#	http://homepage3.nifty.com/slokar/w3m/${P}_256-005.patch.gz
# w3n canna inline patch:
#	canna? ( http://www.j10n.org/files/w3m-cvs-1.914-canna.patch )
# w3m bookmark charset patch:
#	nls? ( ${PATCH_PATH}/w3m-cvs-1.942-nls-2.diff.gz )

LICENSE="w3m"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="X async fbcon gpm gtk imlib lynxkeymap migemo nls ssl unicode xface"
#IUSE="canna"

# canna? ( app-i18n/canna )
# We cannot build w3m with gtk+2 w/o X because gtk+2 ebuild doesn't
# allow us to build w/o X, so we have to give up framebuffer w3mimg....
DEPEND=">=sys-libs/ncurses-5.2-r3
	>=sys-libs/zlib-1.1.3-r2
	>=dev-libs/boehm-gc-6.2
	X? ( || ( x11-libs/libX11 virtual/x11 ) )
	gtk? ( >=x11-libs/gtk+-2 )
	!gtk? ( imlib? ( >=media-libs/imlib2-1.1.0 ) )
	xface? ( media-libs/compface )
	gpm? ( >=sys-libs/gpm-1.19.3-r5 )
	migemo? ( >=app-text/migemo-0.40 )
	ssl? ( >=dev-libs/openssl-0.9.6b )"
PROVIDE="virtual/w3m"

src_unpack() {
	unpack ${P}.tar.gz
	cd ${S}
	epatch ${DISTDIR}/${P}-cvs1.938.diff.gz
	epatch ${FILESDIR}/${PN}-w3mman-gentoo.diff
	epatch ${FILESDIR}/${P}-security.patch

	use async && epatch ${DISTDIR}/w3m-cvs-1.942-async-7.diff.gz

	#epatch ${DISTDIR}/${P}_256-005.patch.gz
	#use canna && epatch ${DISTDIR}/w3m-cvs-1.914-canna.patch
}

src_compile() {

	local myconf migemo_command imagelibval imageval

	if use gtk ; then
		imagelibval="gtk2"
	elif use imlib ; then
		imagelibval="imlib2"
	fi

	if [ ! -z "${imagelibval}" ] ; then
		use X && imageval="${imageval}${imageval:+,}x11"
		use X && use fbcon && imageval="${imageval}${imageval:+,}fb"
	fi

	if use migemo ; then
		migemo_command="migemo -t egrep ${EPREFIX}/usr/share/migemo/migemo-dict"
	else
		migemo_command="no"
	fi

	# emacs-w3m doesn't like "--enable-m17n --disable-unicode,"
	# so we better enable or disable both. Default to enable
	# m17n and unicode, see bug #47046.
	if use linguas_ja ; then
		myconf="${myconf} --enable-japanese=E"
	else
		myconf="${myconf} --with-charset=US-ASCII"
	fi
	if use unicode ; then
		myconf="${myconf} --with-charset=UTF-8"
	fi

	# lynxkeymap IUSE flag. bug #49397
	if use lynxkeymap ; then
		myconf="${myconf} --enable-keymap=lynx"
	else
		myconf="${myconf} --enable-keymap=w3m"
	fi

	econf \
		--with-editor="${EPREFIX}"/usr/bin/nano \
		--with-mailer="${EPREFIX}"/bin/mail \
		--with-browser="${EPREFIX}"/usr/bin/mozilla \
		--with-termlib=curses \
		--enable-image=${imageval:-no} \
		--with-imagelib="${imagelibval:-no}" \
		--with-migemo="${migemo_command}" \
		--enable-m17n \
		--enable-unicode \
		$(use_enable gpm mouse) \
		$(use_enable ssl digest-auth) \
		$(use_with ssl) \
		$(use_enable nls) \
		$(use_enable xface) \
		${myconf} || die
		# $(use_with canna)

	# emake borked
	emake -j1 all || die "make failed"
}

src_install() {

	make DESTDIR=${D} install || die "make install failed"

	insinto /usr/share/${PN}/Bonus
	doins Bonus/*
	dodoc README NEWS TODO ChangeLog
	docinto doc-en ; dodoc doc/*
	if use linguas_ja ; then
		docinto doc-jp ; dodoc doc-jp/*
	else
		rm -rf ${ED}/usr/share/man/ja
	fi
}
