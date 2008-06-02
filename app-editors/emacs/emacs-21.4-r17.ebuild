# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs/emacs-21.4-r17.ebuild,v 1.8 2008/06/01 11:49:14 ulm Exp $

EAPI="prefix"

WANT_AUTOCONF="2.1"

inherit flag-o-matic eutils toolchain-funcs autotools

DESCRIPTION="The extensible, customizable, self-documenting real-time display editor"
HOMEPAGE="http://www.gnu.org/software/emacs/"
SRC_URI="mirror://gnu/emacs/${P}a.tar.gz
	mirror://gentoo/${P}-patches-5.tar.bz2
	leim? ( mirror://gnu/emacs/leim-${PV}.tar.gz )"

LICENSE="GPL-2 FDL-1.1 BSD"
SLOT="21"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="X Xaw3d leim motif nls sendmail"

RDEPEND="sys-libs/ncurses
	X? (
		x11-libs/libXext
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXmu
		x11-libs/libXpm
		x11-misc/emacs-desktop
		>=media-libs/giflib-4.1.0.1b
		>=media-libs/jpeg-6b-r2
		>=media-libs/tiff-3.5.5-r3
		>=media-libs/libpng-1.2.1
		Xaw3d? ( x11-libs/Xaw3d )
		!Xaw3d? ( motif? ( x11-libs/openmotif ) )
	)
	sendmail? ( virtual/mta )
	>=app-admin/eselect-emacs-1.2"

DEPEND="${RDEPEND}
	X? ( x11-misc/xbitmaps )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	EPATCH_SUFFIX=patch epatch

	sed -i \
		-e "s:/usr/lib/crtbegin.o:$(`tc-getCC` -print-file-name=crtbegin.o):g" \
		-e "s:/usr/lib/crtend.o:$(`tc-getCC` -print-file-name=crtend.o):g" \
		"${S}"/src/s/freebsd.h || die "unable to sed freebsd.h settings"

	# install emacsclient.1 man page (bug 165466)
	sed -i -e "s/for page in emacs/& emacsclient/" Makefile.in || die

	# This will need to be updated for X-Compilation
	sed -i -e "s:/usr/lib/\([^ ]*\).o:/usr/$(get_libdir)/\1.o:g" \
		"${S}/src/s/gnu-linux.h" || die

	eautoconf
}

src_compile() {
	export SANDBOX_ON=0

	# -fstack-protector gets internal compiler error at xterm.c (bug 33265)
	filter-flags -fstack-protector

	# emacs doesn't handle LDFLAGS properly (bug #77430 and bug #65002)
	unset LDFLAGS

	# ever since GCC 3.2
	replace-flags -O[3-9] -O2

	# -march is known to cause signal 6 on some environment
	filter-flags "-march=*"

	local myconf
	use nls || myconf="${myconf} --disable-nls"
	if use X ; then
		myconf="${myconf}
			--with-x
			--with-xpm
			--with-jpeg
			--with-tiff
			--with-gif
			--with-png"
		if use Xaw3d ; then
			einfo "Configuring to build with Xaw3d (Athena) toolkit"
			myconf="${myconf} --with-x-toolkit=athena"
		elif use motif ; then
			einfo "Configuring to build with Motif toolkit"
			myconf="${myconf} --with-x-toolkit=motif"
		else
			# do not build emacs with any toolkit, bug 35300
			einfo "Configuring to build with no toolkit"
			myconf="${myconf} --with-x-toolkit=no"
		fi
	else
		myconf="${myconf} --without-x"
	fi
	econf ${myconf} || die "econf failed"
	emake CC="$(tc-getCC)" || die "emake failed"

	einfo "Recompiling patched lisp files..."
	(cd lisp; emake recompile) || die "emake recompile failed"
	(cd src; emake versionclean)
	emake CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	local i m

	einstall || die "einstall failed"
	for i in "${ED}"/usr/bin/* ; do
		mv "${i}" "${i}-emacs-${SLOT}" || die "mv ${i} failed"
	done
	mv "${ED}"/usr/bin/emacs{-emacs,}-${SLOT} || die "mv emacs failed"
	rm "${ED}"/usr/bin/emacs-${PV}-emacs-${SLOT}

	einfo "Fixing info documentation..."
	mkdir "${T}/emacs-${SLOT}"
	mv "${ED}/usr/share/info/dir" "${T}"
	for i in "${ED}"/usr/share/info/*
	do
		mv "${i}" "${T}/emacs-${SLOT}/${i##*/}.info"
	done
	mv "${T}/emacs-${SLOT}" "${ED}/usr/share/info"
	mv "${T}/dir" "${ED}/usr/share/info/emacs-${SLOT}"

	einfo "Fixing manpages..."
	for m in "${ED}"/usr/share/man/man1/* ; do
		mv "${m}" "${m%.1}-emacs-${SLOT}.1" || die "mv ${m} failed"
	done

	# avoid collision between slots
	rm "${ED}"/usr/share/emacs/site-lisp/subdirs.el

	einfo "Fixing permissions..."
	find "${ED}" -perm 664 |xargs chmod -f 644 2>/dev/null
	find "${ED}" -type d |xargs chmod -f 755 2>/dev/null

	keepdir /usr/share/emacs/${PV}/leim
	keepdir /usr/share/emacs/site-lisp

	dodoc BUGS ChangeLog README
}

emacs-infodir-rebuild() {
	# Depending on the Portage version, the Info dir file is compressed
	# or removed. It is only rebuilt by Portage if our directory is in
	# INFOPATH, which is not guaranteed. So we rebuild it ourselves.

	local infodir=/usr/share/info/emacs-${SLOT} f
	einfo "Regenerating Info directory index in ${infodir} ..."
	rm -f "${EROOT}"${infodir}/dir{,.*}
	for f in "${EROOT}"${infodir}/*.info*; do
		[[ ${f##*/} == *[0-9].info* ]] \
			|| install-info --info-dir="${EROOT}"${infodir} "${f}" &>/dev/null
	done
	rmdir "${EROOT}"${infodir} 2>/dev/null # remove dir if it is empty
	echo
}

pkg_postinst() {
	test -f "${EROOT}"/usr/share/emacs/site-lisp/subdirs.el ||
		cp "${EROOT}"/usr/share/emacs{/${PV},}/site-lisp/subdirs.el

	emacs-infodir-rebuild

	if [[ $(readlink "${EROOT}"/usr/bin/emacs) == emacs.emacs-${SLOT}* ]]; then
		# transition from pre-eselect revision
		eselect emacs set emacs-${SLOT}
	else
		eselect emacs update ifunset
	fi

	if ! use sendmail && ! has_version "virtual/mta"; then
		elog "You disabled sendmail support for Emacs. If you later install"
		elog "a MTA then you will need to recompile Emacs. See Bug #11104."
	fi
	if use X; then
		elog "You need to install some fonts for Emacs. Under monolithic"
		elog "XFree86/Xorg you typically had such fonts installed by default."
		elog "With modular Xorg, you will have to perform this step yourself."
		elog "Installing media-fonts/font-adobe-{75,100}dpi on the X server's"
		elog "machine would satisfy basic Emacs requirements under X11."
	fi
}

pkg_postrm() {
	emacs-infodir-rebuild
	eselect emacs update ifunset
}
