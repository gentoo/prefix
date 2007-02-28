# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs/emacs-22.0.50_pre20050225.ebuild,v 1.6 2006/02/27 19:37:06 mkennedy Exp $

EAPI="prefix"

inherit elisp-common alternatives flag-o-matic eutils

IUSE="X Xaw3d aqua cjk gif gnome gtk jpeg multi-tty nls png spell tiff"

INLINE="inline_patch-20041229"
MULTI_TTY="emacs--multi-tty--0--patch-301.2005-02-25"

DESCRIPTION="Emacs is the extensible, customizable, self-documenting real-time display editor."
HOMEPAGE="http://www.gnu.org/software/emacs/
	http://macemacsjp.sourceforge.jp/
	http://lorentey.hu/project/emacs.html.en"
SRC_URI="mirror://gentoo/${P/_pre/-}.tar.gz
	cjk? ( mirror://sourceforge.jp/macemacsjp/12817/${INLINE}.tar.gz )
	multi-tty? ( http://lorentey.hu/downloads/emacs/multi-tty/${MULTI_TTY}.patch.gz )"

RESTRICT="$RESTRICT nostrip"

DEPEND=">=sys-apps/portage-2.0.51
	>=sys-libs/ncurses-5.3
	sys-libs/gdbm
	spell? ( || ( app-text/ispell app-text/aspell ) )
	X? ( || ( ( x11-libs/libXext
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libXmu
				x11-libs/libXpm
				x11-misc/xbitmaps
				|| ( media-fonts/font-adobe-100dpi
					media-fonts/font-adobe-75dpi )
			)
			virtual/x11
		)
		gif? ( >=media-libs/giflib-4.1.0.1b )
		jpeg? ( >=media-libs/jpeg-6b )
		tiff? ( >=media-libs/tiff-3.5.7 )
		png? ( >=media-libs/libpng-1.2.5 )
		gtk? ( =x11-libs/gtk+-2* )
		!gtk? ( Xaw3d? ( x11-libs/Xaw3d ) )
		gnome? ( gnome-base/gnome-desktop ) )
	nls? ( >=sys-devel/gettext-0.11.5 )
	!=app-editors/emacs-cvs-21.3.50*
	!=app-editors/emacs-cvs-22.0.50*"

PROVIDE="virtual/emacs virtual/editor"

SLOT="22.0.50"
LICENSE="GPL-2"
# should run on other arches, but the ebuild is intended for ppc-macos
KEYWORDS="~ppc-macos ~x86-macos"

DFILE=emacs-${SLOT}.desktop

S=${WORKDIR}/${P%_*}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/emacs-subdirs-el-gentoo.diff
	if use ppc-macos ; then
		use cjk && epatch ${WORKDIR}/${INLINE}/emacs-inline.patch
		epatch ${FILESDIR}/emacs-nofink-gentoo.diff
	fi
	if use multi-tty ; then
		if use aqua ; then
			ewarn "Carbon Emacs will not compile with multi-tty patch; disabling multi-tty."
			ewarn "If you want to use multi-tty, please trun off aqua USE flag."
			epause; ebeep; epause
		else
			epatch ../${MULTI_TTY}.patch
		fi
	fi

	# This will need to be updated for X-Compilation
	sed -i -e "s:/usr/lib/\([^ ]*\).o:/usr/$(get_libdir)/\1.o:g" \
		   ${S}/src/s/gnu-linux.h

	sed -i -e "s/-lungif/-lgif/g" configure* src/Makefile.in || die
}

src_compile() {
	SANDBOX_ON=0

	strip-flags

	local myconf

	use nls || myconf="${myconf} --disable-nls"

	if use X; then
		myconf="${myconf} --with-x"
		myconf="${myconf} --with-xpm --with-toolkit-scroll-bars"
		myconf="${myconf} $(use_with jpeg) $(use_with tiff)"
		myconf="${myconf} $(use_with gif) $(use_with png)"
		if use gtk; then
			einfo "Configuring to build with GTK support"
			myconf="${myconf} --with-x-toolkit=gtk"
		elif use Xaw3d; then
			einfo "Configuring to build with Xaw3d support"
			myconf="${myconf} --with-x-toolkit=athena"
		else
			einfo "Configuring to build with lucid toolkit support"
			myconf="${myconf} --without-gtk"
			myconf="${myconf} --with-x-toolkit=lucid"
		fi
	fi

	if use aqua ; then
		einfo "Configuring to build with Carbon Emacs"
		econf --enable-debug \
			--enable-carbon-app=/Applications/Gentoo \
			--without-x \
			$(use_with jpeg) $(use_with tiff) \
			$(use_with gif) $(use_with png) \
			|| die "econf carbon emacs failed"
		emake -j1 || die "make carbon emacs bootstrap failed"
	fi

	econf --enable-debug \
		--program-suffix=.emacs-${SLOT} \
		--without-carbon \
		${myconf} || die "econf emacs failed"

	emake -j1 CC="$(tc-getCC)" || die "make emacs bootstrap failed"
}

src_install () {
	einstall || die
	rm ${ED}/usr/bin/emacs-${SLOT}.emacs-${SLOT} || die "removing duplicate emacs executable failed"
	dohard /usr/bin/emacs.emacs-${SLOT} /usr/bin/emacs-${SLOT} || die

	if use aqua ; then
		einfo "Installing Carbon Emacs..."
		dodir /Applications/Gentoo/Emacs.app
		pushd mac/Emacs.app
		tar -chf - . | ( cd ${ED}/Applications/Gentoo/Emacs.app; tar -xf -)
		popd
	fi

	# fix info documentation
	einfo "Fixing info documentation..."
	dodir /usr/share/info/emacs-${SLOT}
	mv ${ED}/usr/share/info/{,emacs-${SLOT}/}dir || die "mv dir failed"
	for i in ${ED}/usr/share/info/*
	do
		if [ "${i##*/}" != emacs-${SLOT} ] ; then
			mv ${i} ${i/info/info/emacs-${SLOT}}.info
			gzip -9 ${i/info/info/emacs-${SLOT}}.info
		fi
	done

	if has_version 'app-text/aspell' ; then
		# defaults to aspell if installed
		elisp-site-file-install ${FILESDIR}/40aspell-gentoo.el
	fi
	newenvd ${FILESDIR}/60emacs-${SLOT}.envd 60emacs-${SLOT}

	einfo "Fixing manpages..."
	for m in  ${ED}/usr/share/man/man1/* ; do
		mv ${m} ${m/.1/-${SLOT}.1} || die "mv man failed"
	done

	dodoc BUGS ChangeLog README*

	if use gnome; then
		insinto /usr/share/applications
		doins ${FILESDIR}/${DFILE} || die "install desktop file faild"
	fi
}

update-alternatives() {
	for i in emacs emacsclient etags ctags b2m ebrowse \
		rcs-checkin grep-changelog ; do
		alternatives_auto_makesym "/usr/bin/$i" "/usr/bin/$i.emacs-*"
	done
}

pkg_postinst() {
	use ppc-macos || update-alternatives
	if use aqua && use cjk ; then
		einfo
		einfo "If you are going to use Japanese input method on Carbon Emacs,"
		einfo "put the following lines to your ~/.emacs.el"
		einfo "(if (eq window-system 'mac)"
		einfo "	(set-keyboard-coding-system 'sjis)"
		einfo
	fi
}

pkg_postrm() {
	use ppc-macos || update-alternatives
}
