# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rdesktop/rdesktop-1.6.0.ebuild,v 1.6 2008/05/16 19:40:49 dertobi123 Exp $

EAPI="prefix"

inherit eutils

MY_PV=${PV/_/-}

DESCRIPTION="A Remote Desktop Protocol Client"
HOMEPAGE="http://rdesktop.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="ao debug ipv6 oss"

S=${WORKDIR}/${PN}-${MY_PV}

RDEPEND=">=dev-libs/openssl-0.9.6b
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXau
	x11-libs/libXdmcp
	ao? ( >=media-libs/libao-0.8.6 )"
DEPEND="${RDEPEND}
	x11-libs/libXt"

src_compile() {
	sed -i -e '/-O2/c\' -e 'cflags="$cflags ${CFLAGS}"' configure
	local strip="$(echo '$(STRIP) $(DESTDIR)$(bindir)/rdesktop')"
	sed -i -e "s:${strip}::" Makefile.in \
		|| die "sed failed in Makefile.in"

	if use oss; then
		extra_conf=`use_with oss sound`
	else
		extra_conf=`use_with ao sound libao`
	fi

	econf \
		--with-openssl="${EPREFIX}"/usr \
		`use_with debug` \
		`use_with ipv6` \
		${extra_conf} \
		|| die

	emake || die
}

src_install() {
	make DESTDIR="${D}" install
	dodoc doc/HACKING doc/TODO doc/keymapping.txt

	# For #180313 - applies to versions >= 1.5.0
	# Fixes sf.net bug
	# http://sourceforge.net/tracker/index.php?func=detail&aid=1725634&group_id=24366&atid=381349
	# check for next version to see if this needs to be removed
	insinto /usr/share/rdesktop/keymaps
	newins "${FILESDIR}/rdesktop-keymap-additional" additional
	newins "${FILESDIR}/rdesktop-keymap-cs" cs
	newins "${FILESDIR}/rdesktop-keymap-sk" sk
}
