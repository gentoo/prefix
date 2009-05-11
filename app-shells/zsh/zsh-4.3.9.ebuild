# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/zsh/zsh-4.3.9.ebuild,v 1.9 2009/05/07 13:26:39 tove Exp $

# doc package for -dev version exists?
doc_available=true

inherit flag-o-matic eutils multilib prefix

MY_PV=${PV/_p/-dev-}
S=${WORKDIR}/${PN}-${MY_PV}

zsh_ftp="ftp://ftp.zsh.org/pub"

if [[ ${PV} != "${MY_PV}" ]] ; then
	ZSH_URI="${zsh_ftp}/development/${PN}-${MY_PV}.tar.bz2"
	if ${doc_available} ; then
		ZSH_DOC_URI="${zsh_ftp}/development/${PN}-${MY_PV}-doc.tar.bz2"
	else
		ZSH_DOC_URI="${zsh_ftp}/${PN}-${PV%_*}-doc.tar.bz2"
	fi
else
	ZSH_URI="mirror://sourceforge/${PN}/${P}.tar.bz2
		${zsh_ftp}/${P}.tar.bz2"
	ZSH_DOC_URI="${zsh_ftp}/${PN}-${PV%_*}-doc.tar.bz2"
fi

LOVERS_PV=0.5.orig
LOVERS_P=zsh-lovers-${LOVERS_PV}
LOVERS_URI="http://deb.grml.org/pool/main/z/zsh-lovers"

DESCRIPTION="UNIX Shell similar to the Korn shell"
HOMEPAGE="http://www.zsh.org/"
SRC_URI="${ZSH_URI}
	examples? ( ${LOVERS_URI}/zsh-lovers_${LOVERS_PV}.tar.gz )
	doc? ( ${ZSH_DOC_URI} )"

LICENSE="ZSH gdbm? ( GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="caps debug doc examples gdbm maildir pcre static unicode"

RDEPEND=">=sys-libs/ncurses-5.1
	caps? ( sys-libs/libcap )
	pcre? ( >=dev-libs/libpcre-3.9 )
	gdbm? ( sys-libs/gdbm )"
DEPEND="sys-apps/groff
	${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix zshall problem with soelim
	ln -s Doc man1
	mv Doc/zshall.1 Doc/zshall.1.soelim
	soelim Doc/zshall.1.soelim > Doc/zshall.1

	epatch "${FILESDIR}/${PN}"-init.d-gentoo.diff

	cp "${FILESDIR}"/zprofile "${T}"/zprofile
	eprefixify "${T}"/zprofile
}

src_compile() {
	local myconf=

	if use static ; then
		myconf="${myconf} --disable-dynamic"
		append-ldflags -static
	fi
	if use debug ; then
		myconf="${myconf} \
			--enable-zsh-debug \
			--enable-zsh-mem-debug \
			--enable-zsh-mem-warning \
			--enable-zsh-secure-free \
			--enable-zsh-hash-debug"
	fi

	if [[ ${CHOST} == *-darwin* ]]; then
		myconf="${myconf} --enable-libs=-liconv"
		append-ldflags -Wl,-x
	fi

	econf \
		--bindir="${EPREFIX}"/bin \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--enable-etcdir="${EPREFIX}"/etc/zsh \
		--enable-fndir="${EPREFIX}"/usr/share/zsh/${PV%_*}/functions \
		--enable-site-fndir="${EPREFIX}"/usr/share/zsh/site-functions \
		--enable-function-subdirs \
		--enable-ldflags="${LDFLAGS}" \
		--with-term-lib="ncursesw ncurses" \
		--with-tcsetpgrp \
		$(use_enable maildir maildir-support) \
		$(use_enable pcre) \
		$(use_enable caps cap) \
		$(use_enable unicode multibyte) \
		$(use_enable gdbm ) \
		${myconf} || die "configure failed"

	if use static ; then
		# compile all modules statically, see Bug #27392
		# removed cap and curses because linking failes
		sed -i \
			-e "s/link=no/link=static/g" \
			-e 's/cap.mdd link=static/cap.mdd link=no/' \
			-e 's/curses.mdd link=static/curses.mdd link=no/' \
			config.modules || die
		if ! use gdbm ; then
			sed -i 's/gdbm.mdd link=static/gdbm.mdd link=no/' \
				config.modules || die
		fi
#	else
#		sed -i -e "/LIBS/s%-lpcre%${EPREFIX}/usr/$(get_libdir)/libpcre.a%" Makefile
	fi

	emake || die "make failed"
}

src_test() {
	local i
	addpredict /dev/ptmx
	for i in C02cond.ztst Y01completion.ztst Y02compmatch.ztst Y03arguments.ztst ; do
		rm "${S}"/Test/${i} || die
	done
	make check || die "make check failed"
}

src_install() {
	emake DESTDIR="${D}" install install.info || die

	# Bug 207019
	rm "${ED}"/bin/${PN}-${MY_PV} || die

	insinto /etc/zsh
	doins "${T}"/zprofile

	keepdir /usr/share/zsh/site-functions
	insinto /usr/share/zsh/${PV%_*}/functions/Prompts
	newins "${FILESDIR}"/prompt_gentoo_setup-1 prompt_gentoo_setup || die

	# install miscellaneous scripts; bug #54520
	local i
	sed -i -e "s:/usr/local:${EPREFIX}/usr:g" "${S}"/{Util,Misc}/* || die
	for i in Util Misc ; do
		insinto /usr/share/zsh/${PV%_*}/${i}
		doins ${i}/* || die
	done

	dodoc ChangeLog* META-FAQ NEWS README config.modules

	if use doc ; then
		cd "${WORKDIR}/${PN}-${PV%_*}"
		dohtml -r Doc/* || die
		insinto /usr/share/doc/${PF}
		doins Doc/zsh.{dvi,pdf} || die
		cd -
	fi

	if use examples ; then
		cd "${WORKDIR}/${LOVERS_P/.orig/}"
#		asciidoc zsh-lovers.1.txt
#		mv zsh-lovers.1.html zsh-lovers.html
#		a2x -f manpage zsh-lovers.1.txt
#		a2x -f pdf zsh-lovers.1.txt
#		mv zsh-lovers.1.pdf zsh-lovers.pdf

		doman  zsh-lovers.1    || die "doman zsh-lovers failed"
		dohtml zsh-lovers.html || die "dohtml zsh-lovers failed"
		docinto zsh-lovers
		dodoc zsh.vim README   || die
		insinto /usr/share/doc/${PF}/zsh-lovers
#		doins zsh-lovers.pdf refcard.pdf || die
		doins zsh-lovers.{ps,pdf} refcard.{dvi,ps,pdf} || die
		doins -r zsh_people || die "doins zsh_people failed"
		cd -
	fi

	docinto StartupFiles
	dodoc StartupFiles/z*
}

pkg_postinst() {
	# should link to http://www.gentoo.org/doc/en/zsh.xml
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
}
