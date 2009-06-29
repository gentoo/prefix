# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.2.ebuild,v 1.1 2009/06/25 09:20:37 aballier Exp $

EAPI=2
inherit autotools flag-o-matic eutils toolchain-funcs

MY_P=${P/_/}
DESCRIPTION="The Ogg Vorbis sound file format library with aoTuV patch"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://downloads.xiph.org/releases/vorbis/${P}.tar.gz"
#	aotuv? ( mirror://gentoo/${PN}-1.2.1_rc1-aotuv_beta5.7.patch.bz2
#		http://dev.gentoo.org/~ssuominen/${PN}-1.2.1_rc1-aotuv_beta5.7.patch.bz2 )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc"
# +aotuv:  seems it is merged

RDEPEND="media-libs/libogg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_prepare() {
	#use aotuv && epatch "${WORKDIR}"/${PN}-1.2.1_rc1-aotuv_beta5.7.patch

	sed -e 's:-O20::g' -e 's:-mfused-madd::g' -e 's:-mcpu=750::g' \
		-i configure.ac || die "sed failed"
	
	sed -i s/-mv8// configure.ac || die "sed failed"

	AT_M4DIR=m4 eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${ED}"/usr/share/doc/${PN}*

	dodoc AUTHORS CHANGES README todo.txt
	#use aotuv && dodoc aoTuV_README-1st.txt aoTuV_technical.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		docinto html
		dohtml -r doc/*
		insinto /usr/share/doc/${PF}/pdf
		doins doc/*.pdf
	fi
}
