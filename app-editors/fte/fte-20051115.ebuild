# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/fte/fte-20051115.ebuild,v 1.6 2006/11/01 20:51:11 mabi Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Lightweight text-mode editor"
HOMEPAGE="http://fte.sourceforge.net"
SRC_URI="mirror://sourceforge/fte/${P}-src.zip
	mirror://sourceforge/fte/${P}-common.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gpm slang X"
S=${WORKDIR}/${PN}

RDEPEND=">=sys-libs/ncurses-5.2
	X? (
		|| (
			(
				x11-libs/libXdmcp
				x11-libs/libXau
				x11-libs/libX11
			)
		virtual/x11
		)
	)
	gpm? ( >=sys-libs/gpm-1.20 )"
DEPEND="${RDEPEND}
	slang? ( sys-libs/slang )
	app-arch/unzip"

set_targets() {
	export TARGETS=""
	use slang && TARGETS="$TARGETS sfte"
	use X && TARGETS="$TARGETS xfte"

	TARGETS="$TARGETS vfte"
}

src_unpack() {
	unpack ${P}-src.zip
	unpack ${P}-common.zip

	cd ${S}

	epatch ${FILESDIR}/fte-gcc34
	epatch ${FILESDIR}/${PN}-new_keyword.patch

	set_targets
	sed \
		-e "s:@targets@:${TARGETS}:" \
		-e "s:@cflags@:${CFLAGS}:" \
		-i src/fte-unix.mak

	if ! use gpm; then
		sed \
			-e "s:#define USE_GPM://#define USE_GPM:" \
			-i src/con_linux.cpp
		sed \
			-e "s:-lgpm::" \
			-i src/fte-unix.mak
	fi

	if [[ ${KERNEL} == "Linux" ]] ; then

	cat "${EPREFIX}"/usr/include/linux/keyboard.h \
		| grep -v "wait.h" \
		> src/hacked_keyboard.h

	sed \
		-e "s:<linux/keyboard.h>:\"hacked_keyboard.h\":" \
		-i src/con_linux.cpp

	fi
}

src_compile() {
	DEFFLAGS="PREFIX='${EPREFIX}'/usr CONFIGDIR='${EPREFIX}'/usr/share/fte \
		DEFAULT_FTE_CONFIG=../config/main.fte OPTIMIZE="

	set_targets
	emake $DEFFLAGS TARGETS="$TARGETS" all || die
}

src_install() {
	local files

	keepdir /etc/fte

	into /usr

	set_targets
	files="${TARGETS} cfte"

	for i in ${files} ; do
		dobin src/$i ;
	done

	dobin ${FILESDIR}/fte

	dodoc Artistic CHANGES BUGS HISTORY README TODO
	dohtml doc/*

	dodir usr/share/fte
	insinto /usr/share/fte
	doins -r config/*

	rm -rf ${ED}/usr/share/fte/CVS
}

pkg_postinst() {
	ebegin "Compiling configuration"
	cd "${EPREFIX}"/usr/share/fte || die "missing configuration dir"
	"${EPREFIX}"/usr/bin/cfte main.fte "${EPREFIX}"/etc/fte/system.fterc
	eend $?
}
