# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/zsh/zsh-4.2.5.ebuild,v 1.10 2005/09/04 12:23:41 cryos Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="UNIX Shell similar to the Korn shell"
HOMEPAGE="http://www.zsh.org/"
SRC_URI="ftp://ftp.zsh.org/pub/${P}.tar.bz2
	linguas_ja? ( http://www.ono.org/software/dist/${PN}-4.2.4-euc-0.3.patch.gz )
	doc? ( ftp://ftp.zsh.org/pub/${P}-doc.tar.bz2 )"

LICENSE="ZSH"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ~ppc-macos sparc x86"
IUSE="maildir ncurses static doc pcre cap"

RDEPEND="pcre? ( >=dev-libs/libpcre-3.9 )
	cap? ( sys-libs/libcap )
	ncurses? ( >=sys-libs/ncurses-5.1 )"
DEPEND="sys-apps/groff
	>=sys-apps/sed-4
	${RDEPEND}"

src_unpack() {
	unpack ${P}.tar.bz2
	use doc && unpack ${P}-doc.tar.bz2
	cd ${S}
	epatch ${FILESDIR}/${PN}-4.2.1-gentoo.diff
	epatch ${FILESDIR}/${PN}-init.d-gentoo.diff
	use linguas_ja && epatch ${DISTDIR}/${PN}-4.2.4-euc-0.3.patch.gz
	cd ${S}/Doc
	ln -sf . man1
	# fix zshall problem with soelim
	soelim zshall.1 > zshall.1.soelim
	mv zshall.1.soelim zshall.1
}

src_compile() {
	local myconf

	use static && myconf="${myconf} --disable-dynamic" \
		&& LDFLAGS="${LDFLAGS} -static"

	if use userland_Darwin; then
		LDFLAGS="${LDFLAGS} -Wl,-x"
		myconf="${myconf} --enable-libs=-liconv"
	fi

	econf \
		$(with_bindir) \
		--libdir=${PREFIX}/usr/$(get_libdir) \
		--enable-etcdir=${PREFIX}/etc/zsh \
		--enable-zshenv=${PREFIX}/etc/zsh/zshenv \
		--enable-zlogin=${PREFIX}/etc/zsh/zlogin \
		--enable-zlogout=${PREFIX}/etc/zsh/zlogout \
		--enable-zprofile=${PREFIX}/etc/zsh/zprofile \
		--enable-zshrc=${PREFIX}/etc/zsh/zshrc \
		--enable-fndir=${PREFIX}/usr/share/zsh/${PV%_*}/functions \
		--enable-site-fndir=${PREFIX}/usr/share/zsh/site-functions \
		--enable-function-subdirs \
		--enable-ldflags="${LDFLAGS}" \
		--with-tcsetpgrp \
		$(use_with ncurses curses-terminfo) \
		$(use_enable maildir maildir-support) \
		$(use_enable pcre) \
		$(use_enable cap) \
		${myconf} || die "configure failed"

	if use static ; then
		# compile all modules statically, see Bug #27392
		sed -i -e "s/link=no/link=static/g" \
			-e "s/load=no/load=yes/g" \
			config.modules || die
	else
		# avoid linking to libs in /usr/lib, see Bug #27064
		sed -i -e "/LIBS/s%-lpcre%/${PREFIX}usr/lib/libpcre.a%" \
			Makefile || die
	fi

	# hack for Darwin8 broken poll()
	if use userland_Darwin ; then
		sed -i -e "s/#define HAVE_POLL 1/#undef HAVE_POLL/g" \
			config.h
	fi

	# emake still b0rks
	emake -j1 || die "make failed"
}

src_test() {
	for f in /dev/pt* ; do
		addpredict $f
	done
	make check || die "make check failed"
}

src_install() {
	einstall \
		bindir=${D}/bin \
		libdir=${D}/usr/$(get_libdir) \
		fndir=${D}/usr/share/zsh/${PV%_*}/functions \
		sitefndir=${D}/usr/share/zsh/site-functions \
		install.bin install.man install.modules \
		install.info install.fns || die "make install failed"

	insinto /etc/zsh
	doins ${FILESDIR}/zprofile

	keepdir /usr/share/zsh/site-functions
	insinto /usr/share/zsh/${PV%_*}/functions/Prompts
	doins ${FILESDIR}/prompt_gentoo_setup || die

	# install miscellaneous scripts; bug #54520
	sed -i -e "s:/usr/local:${PREFIX}/usr:g" {Util,Misc}/* || "sed failed"
	insinto /usr/share/zsh/${PV%_*}/Util
	doins Util/* || die "doins Util scripts failed"
	insinto /usr/share/zsh/${PV%_*}/Misc
	doins Misc/* || die "doins Misc scripts failed"

	dodoc ChangeLog* META-FAQ README INSTALL LICENCE config.modules

	if use doc ; then
		dohtml Doc/*
		insinto /usr/share/doc/${PF}
		doins Doc/zsh{.dvi,_us.ps,_a4.ps}
	fi

	docinto StartupFiles
	dodoc StartupFiles/z*
}

pkg_preinst() {
	# Our zprofile file does the job of the old zshenv file
	# Move the old version into a zprofile script so the normal
	# etc-update process will handle any changes.
	if [ -f ${PREFIX}/etc/zsh/zshenv -a ! -f ${PREFIX}/etc/zsh/zprofile ]; then
		mv ${PREFIX}/etc/zsh/zshenv ${PREFIX}/etc/zsh/zprofile
	fi
}

pkg_postinst() {
	einfo
	einfo "If you want to enable Portage completions and Gentoo prompt,"
	einfo "emerge app-shells/zsh-completion and add"
	einfo "	autoload -U compinit promptinit"
	einfo "	compinit"
	einfo "	promptinit; prompt gentoo"
	einfo "to your ~/.zshrc"
	einfo
	einfo "Also, if you want to enable cache for the completions, add"
	einfo "	zstyle ':completion::complete:*' use-cache 1"
	einfo "to your ~/.zshrc"
	einfo
	# see Bug 26776
	ewarn
	ewarn "If you are upgrading from zsh-4.0.x you may need to"
	ewarn "remove all your old ~/.zcompdump files in order to use"
	ewarn "completion.  For more info see zcompsys manpage."
	ewarn
}
