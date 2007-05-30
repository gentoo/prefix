# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs-cvs/emacs-cvs-23.0.0-r6.ebuild,v 1.12 2007/05/23 10:29:12 ulm Exp $

EAPI="prefix"

ECVS_AUTH="pserver"
ECVS_SERVER="cvs.savannah.gnu.org:/sources/emacs"
ECVS_MODULE="emacs"
ECVS_LOCALNAME="emacs-unicode"
ECVS_BRANCH="emacs-unicode-2"

WANT_AUTOCONF="2.61"
WANT_AUTOMAKE="latest"

inherit autotools cvs elisp-common eutils flag-o-matic

DESCRIPTION="The extensible, customizable, self-documenting real-time display editor"
SRC_URI=""
HOMEPAGE="http://www.gnu.org/software/emacs/"
IUSE="alsa gif gtk gzip-el hesiod jpeg lesstif motif png spell sound source tiff toolkit-scroll-bars X Xaw3d xft xpm"

RESTRICT="strip"

X_DEPEND="x11-libs/libXmu x11-libs/libXt x11-misc/xbitmaps"

RDEPEND="sys-libs/ncurses
	>=app-admin/eselect-emacs-0.7-r1
	sys-libs/zlib
	hesiod? ( net-dns/hesiod )
	spell? ( || ( app-text/ispell app-text/aspell ) )
	alsa? ( media-sound/alsa-headers )
	X? (
		$X_DEPEND
		x11-misc/emacs-desktop
		gif? ( media-libs/giflib )
		jpeg? ( media-libs/jpeg )
		tiff? ( media-libs/tiff )
		png? ( media-libs/libpng )
		xpm? ( x11-libs/libXpm )
		xft? ( media-libs/fontconfig virtual/xft >=dev-libs/libotf-0.9.4 )
		gtk? ( =x11-libs/gtk+-2* )
		!gtk? (
			Xaw3d? ( x11-libs/Xaw3d )
			!Xaw3d? (
				motif? ( x11-libs/openmotif )
				!motif? ( lesstif? ( x11-libs/lesstif ) )
			)
		)
	)"

DEPEND="${RDEPEND}
	gzip-el? ( app-arch/gzip )"

PROVIDE="virtual/editor"

SLOT="23"
LICENSE="GPL-2 FDL-1.2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
S="${WORKDIR}/${ECVS_LOCALNAME}"

src_unpack() {
	cvs_src_unpack

	cd "${S}"
	epatch "${FILESDIR}"/emacs-cvs-nofink.patch
	# FULL_VERSION keeps the full version number, which is needed in
	# order to determine some path information correctly for copy/move
	# operations later on
	FULL_VERSION=$(grep 'defconst[	 ]*emacs-version' lisp/version.el \
		| sed -e 's/^[^"]*"\([^"]*\)".*$/\1/')
	[ "${FULL_VERSION}" ] || die "Cannot determine current Emacs version"
	echo
	einfo "Emacs version number is ${FULL_VERSION}"
	echo

	sed -i -e "s:/usr/lib/crtbegin.o:$(`tc-getCC` -print-file-name=crtbegin.o):g" \
		-e "s:/usr/lib/crtend.o:$(`tc-getCC` -print-file-name=crtend.o):g" \
		"${S}"/src/s/freebsd.h || die "unable to sed freebsd.h settings"
	if ! use gzip-el; then
		# Emacs' build system automatically detects the gzip binary and
		# compresses el files. We don't want that so confuse it with a
		# wrong binary name
		sed -i -e "s/ gzip/ PrEvEnTcOmPrEsSiOn/" configure.in \
			|| die "unable to sed configure.in"
	fi

	epatch "${FILESDIR}/${PN}-Xaw3d-headers.patch"
	epatch "${FILESDIR}/${PN}-freebsd-sparc.patch"
	# ALSA is detected and used even if not requested by the USE=alsa flag.
	# So remove the automagic check
	use alsa || epatch "${FILESDIR}/${PN}-disable_alsa_detection.patch"

	eautoreconf
}

src_compile() {
	export SANDBOX_ON=0			# for the unbelievers, see Bug #131505
	ALLOWED_FLAGS=""
	strip-flags
	unset LDFLAGS
	replace-flags -O[3-9] -O2
	sed -i -e "s/-lungif/-lgif/g" configure* src/Makefile* || die

	local myconf

	if use alsa && ! use sound; then
		echo
		einfo "Although sound USE flag is disabled you chose to have alsa,"
		einfo "so sound is switched on anyway."
		echo
		myconf="${myconf} --with-sound"
	else
		myconf="${myconf} $(use_with sound)"
	fi

	if use X; then
		# GTK+ is the default toolkit if USE=gtk is chosen with other
		# possibilities. Emacs upstream thinks this should be standard
		# policy on all distributions
		myconf="${myconf} --with-x"
		myconf="${myconf} $(use_with xpm)"
		myconf="${myconf} $(use_with toolkit-scroll-bars)"
		myconf="${myconf} $(use_enable xft font-backend)"
		myconf="${myconf} $(use_with xft freetype)"
		myconf="${myconf} $(use_with xft)"
		myconf="${myconf} $(use_with jpeg) $(use_with tiff)"
		myconf="${myconf} $(use_with gif) $(use_with png)"
		if use gtk; then
			echo
			einfo "Configuring to build with GTK support, disabling all other toolkits"
			echo
			myconf="${myconf} --with-x-toolkit=gtk"
		elif use Xaw3d; then
			einfo "Configuring to build with Xaw3d(athena) support"
			myconf="${myconf} --with-x-toolkit=athena"
			myconf="${myconf} --without-gtk"
		elif use motif; then
			einfo "Configuring to build with motif toolkit support"
			myconf="${myconf} --without-gtk"
			myconf="${myconf} --with-x-toolkit=motif"
		elif use lesstif; then
			einfo "Configuring to build with lesstif toolkit support"
			myconf="${myconf} --without-gtk"
			myconf="${myconf} --with-x-toolkit=motif"
		fi
	else
		myconf="${myconf} --without-x"
	fi

	# $(use_with hesiod) is not possible, as "--without-hesiod" breaks
	# the build system (has been reported upstream)
	use hesiod && myconf="${myconf} --with-hesiod"

	if use aqua; then
		einfo "Configuring to build with Carbon Emacs"
		econf \
			--enable-carbon-app="${EPREFIX}"/Applications \
			--program-suffix=-emacs-${SLOT} \
			--without-x \
			$(use_with jpeg) $(use_with tiff) \
			$(use_with gif) $(use_with png) \
			$(use_enable xft font-backend) \
			 || die "econf carbon emacs failed"
		make bootstrap || die "make carbon emacs bootstrap failed"
	else # crappy indenting to keep diff small

	econf \
		--program-suffix=-emacs-${SLOT} \
		--without-carbon \
		${myconf} || die "econf emacs failed"

	fi # end crappy indenting

	emake -j1 CC="$(tc-getCC) " bootstrap \
		|| die "make bootstrap failed."
}

src_install () {
	emake install DESTDIR="${D}" || die "make install failed"

	rm "${ED}"/usr/bin/emacs-${FULL_VERSION}-emacs-${SLOT} \
		|| die "removing duplicate emacs executable failed"
	mv "${ED}"/usr/bin/emacs-emacs-${SLOT} "${ED}"/usr/bin/emacs-${SLOT} \
		|| die "moving Emacs executable failed"

	if use aqua ; then
		einfo "Installing Carbon Emacs..."
		dodir /Applications/Emacs.app
		pushd mac/Emacs.app
		tar -chf - . | ( cd ${ED}/Applications/Emacs.app; tar -xf -)
		popd
	fi

	# move info documentation to the correct place
	einfo "Fixing info documentation..."
	dodir /usr/share/info/emacs-${SLOT}
	mv "${ED}"/usr/share/info/{,emacs-${SLOT}/}dir || die "mv dir failed"
	for i in "${ED}"/usr/share/info/*
	do
		if [ "${i##*/}" != emacs-${SLOT} ] ; then
			mv ${i} ${i/info/info/emacs-${SLOT}}.info
		fi
	done

	# move man pages to the correct place
	einfo "Fixing manpages..."
	for m in "${ED}"/usr/share/man/man1/* ; do
		mv ${m} ${m%.1}-emacs-${SLOT}.1 || die "mv man failed"
	done

	# avoid collision between slots, see bug #169033 e.g.
	rm "${ED}"/usr/share/emacs/site-lisp/subdirs.el
	rm "${ED}"/var/lib/games/emacs/{snake,tetris}-scores
	keepdir /var/lib/games/emacs/

	if use source; then
		insinto /usr/share/emacs/${FULL_VERSION}/src
		# This is not meant to install all the source -- just the
		# C source you might find via find-function
		doins src/*.[ch]
		sed 's/^X//' >00emacs-cvs-${SLOT}-gentoo.el <<EOF
(if (string-match "\\\\\`${FULL_VERSION//./\\\\.}\\\\>" emacs-version)
X    (setq find-function-C-source-directory
X	  "${EPREFIX}/usr/share/emacs/${FULL_VERSION}/src"))
EOF
		elisp-site-file-install 00emacs-cvs-${SLOT}-gentoo.el
	fi

	dodoc AUTHORS BUGS CONTRIBUTE README README.unicode || die "dodoc failed"
}

emacs-infodir-rebuild() {
	# Depending on the Portage version, the Info dir file is compressed
	# or removed. It is only rebuilt by Portage if our directory is in
	# INFOPATH, which is not guaranteed. So we rebuild it ourselves.

	local infodir=/usr/share/info/emacs-${SLOT} f
	einfo "Regenerating Info directory index in ${infodir} ..."
	rm -f ${EROOT}${infodir}/dir{,.*}
	for f in ${EROOT}${infodir}/*.info*; do
		[[ ${f##*/} == *[0-9].info* ]] \
			|| install-info --info-dir=${EROOT}${infodir} ${f} &>/dev/null
	done
	echo
}

pkg_postinst() {
	test -f ${EROOT}/usr/share/emacs/site-lisp/subdirs.el ||
		cp ${EROOT}/usr/share/emacs{/${FULL_VERSION},}/site-lisp/subdirs.el

	elisp-site-regen
	emacs-infodir-rebuild
	eselect emacs update --if-unset

	if use X; then
		elog "You need to install some fonts for Emacs. Under monolithic"
		elog "XFree86/Xorg you typically had such fonts installed by default."
		elog "With modular Xorg, you will have to perform this step yourself."
		elog "Installing media-fonts/font-adobe-{75,100}dpi on the X server's"
		elog "machine would satisfy basic Emacs requirements under X11."
	fi

	echo
	elog "You can set the version to be started by /usr/bin/emacs through"
	elog "the Emacs eselect module. Man and info pages are automatically"
	elog "redirected, so you are to test emacs-cvs along with the stable"
	elog "release. \"man emacs.eselect\" for details."
}

pkg_postrm() {
	elisp-site-regen
	emacs-infodir-rebuild
	eselect emacs update --if-unset
}
