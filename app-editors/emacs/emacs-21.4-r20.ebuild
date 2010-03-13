# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/emacs/emacs-21.4-r20.ebuild,v 1.2 2010/03/11 08:50:36 ulm Exp $

EAPI=2

inherit flag-o-matic eutils toolchain-funcs autotools

DESCRIPTION="The extensible, customizable, self-documenting real-time display editor"
HOMEPAGE="http://www.gnu.org/software/emacs/"
SRC_URI="mirror://gnu/emacs/${P}a.tar.gz
	mirror://gentoo/${P}-patches-11.tar.bz2
	leim? ( mirror://gnu/emacs/leim-${PV}.tar.gz )"

LICENSE="GPL-2 FDL-1.1 BSD as-is MIT"
SLOT="21"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="X Xaw3d leim motif sendmail"

DEPEND="sys-libs/ncurses
	>=app-admin/eselect-emacs-1.2
	X? (
		x11-libs/libXext
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXmu
		x11-libs/libXpm
		x11-misc/xbitmaps
		>=media-libs/giflib-4.1.0.1b
		>=media-libs/jpeg-6b-r2:0
		>=media-libs/tiff-3.5.5-r3
		>=media-libs/libpng-1.2.1
		Xaw3d? ( x11-libs/Xaw3d )
		!Xaw3d? ( motif? ( x11-libs/openmotif ) )
	)"

RDEPEND="${DEPEND}
	>=app-emacs/emacs-common-gentoo-1[X?]
	sendmail? ( virtual/mta )"

src_prepare() {
	EPATCH_SUFFIX=patch epatch

	sed -i \
		-e "s:/usr/lib/crtbegin.o:$(`tc-getCC` -print-file-name=crtbegin.o):g" \
		-e "s:/usr/lib/crtend.o:$(`tc-getCC` -print-file-name=crtend.o):g" \
		"${S}"/src/s/freebsd.h || die "unable to sed freebsd.h settings"

	# This will need to be updated for X-Compilation
	sed -i -e "s:/usr/lib/\([^ ]*\).o:/usr/$(get_libdir)/\1.o:g" \
		"${S}/src/s/gnu-linux.h" || die

	# custom aclocal.m4 was only needed for autoconf 2.13 and earlier
	rm aclocal.m4
	eaclocal
	eautoconf
}

src_configure() {
	# -fstack-protector gets internal compiler error at xterm.c (bug 33265)
	filter-flags -fstack-protector

	# emacs doesn't handle LDFLAGS properly (bug #77430 and bug #65002)
	unset LDFLAGS

	# ever since GCC 3.2
	replace-flags -O[3-9] -O2

	# -march is known to cause signal 6 on some environment
	filter-flags "-march=*"

	local myconf
	if use X ; then
		myconf="${myconf}
			--with-x
			--with-xpm
			--with-jpeg
			--with-tiff
			--with-gif
			--with-png"

		if use Xaw3d ; then
			einfo "Configuring to build with Xaw3d (Athena/Lucid) toolkit"
			myconf="${myconf} --with-x-toolkit=athena"
			use motif \
				&& ewarn "USE flag \"motif\" ignored (superseded by \"Xaw3d\")"
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
}

src_compile() {
	export SANDBOX_ON=0
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

	# move info documentation to the correct place
	mkdir "${T}/emacs-${SLOT}"
	mv "${ED}/usr/share/info/dir" "${T}"
	for i in "${ED}"/usr/share/info/*
	do
		mv "${i}" "${T}/emacs-${SLOT}/${i##*/}.info"
	done
	mv "${T}/emacs-${SLOT}" "${ED}/usr/share/info"
	mv "${T}/dir" "${ED}/usr/share/info/emacs-${SLOT}"

	# move man pages to the correct place
	for m in "${ED}"/usr/share/man/man1/* ; do
		mv "${m}" "${m%.1}-emacs-${SLOT}.1" || die "mv ${m} failed"
	done

	# avoid collision between slots
	rm "${ED}"/usr/share/emacs/site-lisp/subdirs.el

	# fix permissions
	find "${ED}" -perm 664 |xargs chmod -f 644 2>/dev/null
	find "${ED}" -type d |xargs chmod -f 755 2>/dev/null

	keepdir /usr/share/emacs/${PV}/leim

	dodoc BUGS ChangeLog README
}

emacs-infodir-rebuild() {
	# Depending on the Portage version, the Info dir file is compressed
	# or removed. It is only rebuilt by Portage if our directory is in
	# INFOPATH, which is not guaranteed. So we rebuild it ourselves.

	local infodir=/usr/share/info/emacs-${SLOT} f
	[ -d "${EROOT}"${infodir} ] || return	# may occur with FEATURES=noinfo
	einfo "Regenerating Info directory index in ${infodir} ..."
	rm -f "${EROOT}"${infodir}/dir{,.*}
	for f in "${EROOT}"${infodir}/*.info*; do
		[[ ${f##*/} != *[0-9].info* && -e ${f} ]] \
			&& install-info --info-dir="${EROOT}"${infodir} "${f}" &>/dev/null
	done
	rmdir "${EROOT}"${infodir} 2>/dev/null	# remove dir if it is empty
}

pkg_postinst() {
	emacs-infodir-rebuild
	eselect emacs update ifunset

	if ! use sendmail && ! has_version "virtual/mta"; then
		elog "You disabled sendmail support for Emacs. If you later install"
		elog "a MTA then you will need to recompile Emacs. See Bug #11104."
	fi

	if use X; then
		echo
		elog "You need to install some fonts for Emacs."
		elog "Installing media-fonts/font-adobe-{75,100}dpi on the X server's"
		elog "machine would satisfy basic Emacs requirements under X11."
	fi
}

pkg_postrm() {
	emacs-infodir-rebuild
	eselect emacs update ifunset
}
