# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/zsh/zsh-4.3.2-r2.ebuild,v 1.10 2007/03/17 21:13:50 vapier Exp $

EAPI="prefix"

inherit eutils multilib

LOVERS_PV=0.5
LOVERS_P=zsh-lovers-${LOVERS_PV}

DESCRIPTION="UNIX Shell similar to the Korn shell"
HOMEPAGE="http://www.zsh.org/"
SRC_URI="ftp://ftp.zsh.org/pub/${P}.tar.bz2
	examples? (
	http://www.grml.org/repos/zsh-lovers_${LOVERS_PV}.orig.tar.gz )
	doc? ( ftp://ftp.zsh.org/pub/${P}-doc.tar.bz2 )"

LICENSE="ZSH"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="maildir ncurses static doc examples pcre caps unicode"

RDEPEND="pcre? ( >=dev-libs/libpcre-3.9 )
	caps? ( sys-libs/libcap )
	ncurses? ( >=sys-libs/ncurses-5.1 )"
DEPEND="sys-apps/groff
	>=sys-apps/sed-4
	${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}-init.d-gentoo.diff
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

	if [[ ${CHOST} == *darwin* ]]; then
		LDFLAGS="${LDFLAGS} -Wl,-x"
		myconf="${myconf} --enable-libs=-liconv"
	fi

	econf \
		--bindir="${EPREFIX}"/bin \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-etcdir="${EPREFIX}"/etc/zsh \
		--enable-zshenv="${EPREFIX}"/etc/zsh/zshenv \
		--enable-zlogin="${EPREFIX}"/etc/zsh/zlogin \
		--enable-zlogout="${EPREFIX}"/etc/zsh/zlogout \
		--enable-zprofile="${EPREFIX}"/etc/zsh/zprofile \
		--enable-zshrc="${EPREFIX}"/etc/zsh/zshrc \
		--enable-fndir="${EPREFIX}"/usr/share/zsh/${PV%_*}/functions \
		--enable-site-fndir="${EPREFIX}"/usr/share/zsh/site-functions \
		--enable-function-subdirs \
		--enable-ldflags="${LDFLAGS}" \
		--with-tcsetpgrp \
		$(use_with ncurses curses-terminfo) \
		$(use_enable maildir maildir-support) \
		$(use_enable pcre) \
		$(use_enable caps) \
		$(use_enable unicode multibyte) \
		${myconf} || die "configure failed"

	if use static ; then
		# compile all modules statically, see Bug #27392
		sed -i -e "s/link=no/link=static/g" \
			-e "s/load=no/load=yes/g" \
			config.modules || die
	else
		# avoid linking to libs in /usr/lib, see Bug #27064
		sed -i -e "/LIBS/s%-lpcre%/usr/$(get_libdir)/libpcre.a%" \
			Makefile || die
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
		bindir=${ED}/bin \
		libdir=${ED}/usr/$(get_libdir) \
		fndir=${ED}/usr/share/zsh/${PV%_*}/functions \
		sitefndir=${ED}/usr/share/zsh/site-functions \
		scriptdir=${ED}/usr/share/zsh/${PV%_*}/scripts \
		install.bin install.man install.modules \
		install.info install.fns || die "make install failed"

	insinto /etc/zsh
	doins ${FILESDIR}/zprofile

	keepdir /usr/share/zsh/site-functions
	insinto /usr/share/zsh/${PV%_*}/functions/Prompts
	doins ${FILESDIR}/prompt_gentoo_setup || die

	# install miscellaneous scripts; bug #54520
	sed -i -e "s:/usr/local:${EPREFIX}/usr:g" {Util,Misc}/* || "sed failed"
	insinto /usr/share/zsh/${PV%_*}/Util
	doins Util/* || die "doins Util scripts failed"
	insinto /usr/share/zsh/${PV%_*}/Misc
	doins Misc/* || die "doins Misc scripts failed"

	dodoc ChangeLog* META-FAQ README INSTALL LICENCE config.modules

	if use doc ; then
		dohtml Doc/*
		insinto /usr/share/doc/${PF}
		doins Doc/zsh.{dvi,pdf}
	fi

	if use examples; then
		cd ${WORKDIR}/${LOVERS_P}
		doman  zsh-lovers.1    || die "doman zsh-lovers failed"
		dohtml zsh-lovers.html || die "dohtml zsh-lovers failed"
		docinto zsh-lovers
		dodoc zsh.vim README
		insinto /usr/share/doc/${PF}/zsh-lovers
		doins zsh-lovers.{ps,pdf} refcard.{dvi,ps,pdf}
		doins -r zsh_people || die "doins zsh_people failed"
		cd -
	fi

	docinto StartupFiles
	dodoc StartupFiles/z*
}

pkg_preinst() {
	# Our zprofile file does the job of the old zshenv file
	# Move the old version into a zprofile script so the normal
	# etc-update process will handle any changes.
	if [ -f "${EROOT}"/etc/zsh/zshenv -a ! -f "${EROOT}"/etc/zsh/zprofile ]; then
		mv "${EROOT}"/etc/zsh/zshenv "${EROOT}"/etc/zsh/zprofile
	fi
}

pkg_postinst() {
	elog
	elog "If you want to enable Portage completions and Gentoo prompt,"
	elog "emerge app-shells/zsh-completion and add"
	elog "	autoload -U compinit promptinit"
	elog "	compinit"
	elog "	promptinit; prompt gentoo"
	elog "to your ~/.zshrc"
	elog
	elog "Also, if you want to enable cache for the completions, add"
	elog "	zstyle ':completion::complete:*' use-cache 1"
	elog "to your ~/.zshrc"
	elog
	# see Bug 26776
	ewarn
	ewarn "If you are upgrading from zsh-4.0.x you may need to"
	ewarn "remove all your old ~/.zcompdump files in order to use"
	ewarn "completion.  For more info see zcompsys manpage."
	ewarn
}
