# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs-cvs/emacs-cvs-23.0.0-r1.ebuild,v 1.9 2007/03/18 15:31:37 grobian Exp $

EAPI="prefix"

ECVS_AUTH="pserver"
ECVS_SERVER="cvs.savannah.gnu.org:/sources/emacs"
ECVS_MODULE="emacs"
ECVS_BRANCH="emacs-unicode-2"

inherit elisp-common cvs alternatives flag-o-matic eutils

IUSE="X Xaw3d aqua gif gtk jpeg nls png spell tiff source gzip-el toolkit-scroll-bars xft"

S=${WORKDIR}/emacs

DESCRIPTION="Emacs is the extensible, customizable, self-documenting real-time display editor."
SRC_URI=""
HOMEPAGE="http://www.gnu.org/software/emacs"

RESTRICT="$RESTRICT nostrip"

X_DEPEND="x11-libs/libXmu x11-libs/libXpm x11-libs/libXt x11-misc/xbitmaps || ( media-fonts/font-adobe-100dpi media-fonts/font-adobe-75dpi )"

DEPEND=">=sys-libs/ncurses-5.3
	spell? ( || ( app-text/ispell app-text/aspell ) )
	X? ( $X_DEPEND )
	X? ( gif? ( >=media-libs/giflib-4.1.0.1b )
		jpeg? ( >=media-libs/jpeg-6b )
		tiff? ( >=media-libs/tiff-3.5.7 )
		png? ( >=media-libs/libpng-1.2.5 )
		gtk? ( =x11-libs/gtk+-2* )
		!gtk? ( Xaw3d? ( x11-libs/Xaw3d ) )
		xft? ( media-libs/fontconfig virtual/xft >=dev-libs/libotf-0.9.4 ) )
	sys-libs/zlib"

PROVIDE="virtual/emacs virtual/editor"

SLOT="23.0.0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"

DFILE=emacs-${SLOT}.desktop

src_unpack() {
	cvs_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/emacs-subdirs-el-gentoo.diff
	epatch "${FILESDIR}"/emacs-cvs-nofink.patch
	epatch "${FILESDIR}"/emacs-cvs-darwin-fsf-gcc.patch
	sed -i -e "s:/usr/lib/crtbegin.o:$(`tc-getCC` -print-file-name=crtbegin.o):g" \
		-e "s:/usr/lib/crtend.o:$(`tc-getCC` -print-file-name=crtend.o):g" \
		"${S}"/src/s/freebsd.h || die "unable to sed freebsd.h settings"
	epatch "${FILESDIR}"/${PN}-freebsd-sparc.patch
}

src_compile() {
	export SANDBOX_ON=0			# for the unbelievers, see Bug #131505
	ALLOWED_FLAGS=" "
	strip-flags
	unset LDFLAGS
	replace-flags -O[3-9] -O2
	sed -i -e "s/-lungif/-lgif/g" configure* src/Makefile* || die

	local myconf

	if use X; then
		myconf="${myconf} --with-x"
		myconf="${myconf} --with-xpm"
		myconf="${myconf} $(use_with toolkit-scroll-bars)"
		myconf="${myconf} $(use_enable xft font-backend)"
		myconf="${myconf} $(use_with xft freetype)"
		myconf="${myconf} $(use_with xft)"
		myconf="${myconf} $(use_with jpeg) $(use_with tiff)"
		myconf="${myconf} $(use_with gif) $(use_with png)"
		if use gtk; then
			einfo "Configuring to build with GTK support"
			myconf="${myconf} --with-x-toolkit=gtk"
		else
			einfo "Configuring to build with lucid toolkit support"
			myconf="${myconf} $(use_with Xaw3d toolkit-scroll-bars)"
			myconf="${myconf} --without-gtk"
			myconf="${myconf} --with-x-toolkit=lucid"
		fi
	else
		myconf="${myconf} --without-x"
	fi
	if use aqua; then
		einfo "Configuring to build with Carbon Emacs"
		econf --enable-debug \
			--enable-carbon-app="${EPREFIX}"/Applications/Gentoo \
			--program-suffix=.emacs-${SLOT} \
			--without-x \
			$(use_with jpeg) $(use_with tiff) \
			$(use_with gif) $(use_with png) \
			$(use_enable xft font-backend) \
			 || die "econf carbon emacs failed"
		make bootstrap || die "make carbon emacs bootstrap failed"
	else
		econf --enable-debug \
			--program-suffix=.emacs-${SLOT} \
			--without-carbon \
			${myconf} || die "econf emacs failed"
		make bootstrap || die "make emacs bootstrap failed"
	fi
}

src_install () {
	make DESTDIR=${D} install || die
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
		fi
	done

	insinto /etc/env.d
	cat >${ED}/etc/env.d/50emacs-cvs-${SLOT} <<EOF
INFOPATH=${EPREFIX}/usr/share/info/emacs-${SLOT}
EOF
	einfo "Fixing manpages..."
	for m in  ${ED}/usr/share/man/man1/* ; do
		mv ${m} ${m/.1/.emacs-${SLOT}.1} || die "mv man failed"
	done

	if use source; then
		insinto /usr/share/emacs/${SLOT}/src
		# This is not meant to install all the source -- just the
		# C source you might find via find-function
		doins src/*.[ch]
		cat >00emacs-cvs-${SLOT}-gentoo.el <<EOF
(when (substring emacs-version 0 (length "${SLOT}"))
  (setq find-function-C-source-directory "${EPREFIX}/usr/share/emacs/${SLOT}/src"))
EOF
		elisp-site-file-install 00emacs-cvs-${SLOT}-gentoo.el
	fi


	if ! use gzip-el; then
		find ${ED} -type f -name \*.el.gz -print0 |xargs -0 gunzip
	fi
	dodoc BUGS ChangeLog ChangeLog.unicode README README.unicode
	insinto /usr/share/applications
	cp ${FILESDIR}/emacs.desktop.in ${DFILE}
	sed -i -e "s,@PV@,${SLOT},g" ${DFILE}
	doins ${DFILE}
}

update-alternatives() {
	for i in emacs emacsclient etags ctags b2m ebrowse \
		rcs-checkin grep-changelog ; do
		alternatives_auto_makesym "/usr/bin/$i" "/usr/bin/$i.emacs-*"
	done
}

pkg_postinst() {
	update-alternatives
	elisp-site-regen
	if use X; then
		while read line; do einfo "${line}"; done<<'EOF'

You need to install some fonts for Emacs.  Under monolithic
XFree86/Xorg you typically had such fonts installed by default.	 With
modular Xorg, you will have to perform this step yourself.

Installing media-fonts/font-adobe-{75,100}dpi would satisfy basic
Emacs requirements under X11.

EOF
	fi
}

pkg_postrm() {
	update-alternatives
	elisp-site-regen
}
