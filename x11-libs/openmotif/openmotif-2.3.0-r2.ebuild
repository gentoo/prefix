# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/openmotif/openmotif-2.3.0-r2.ebuild,v 1.6 2008/05/04 11:13:23 ulm Exp $

EAPI="prefix"

inherit eutils flag-o-matic multilib autotools

DESCRIPTION="Open Motif"
HOMEPAGE="http://www.motifzone.org/"
SRC_URI="ftp://ftp.ics.com/openmotif/2.3/${PV}/${P}.tar.gz
	doc? ( http://www.motifzone.net/files/documents/${P}-manual.pdf.tgz )"

LICENSE="MOTIF libXpm doc? ( OPL )"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc examples jpeg png xft"

# make people unmerge motif-config and all previous slots
# since the slotting is finally gone now
RDEPEND="!x11-libs/motif-config
	!x11-libs/lesstif
	!<=x11-libs/openmotif-2.3.0
	x11-libs/libXmu
	x11-libs/libXaw
	x11-libs/libXp
	virtual/libiconv
	xft? ( x11-libs/libXft )
	jpeg? ( media-libs/jpeg )
	png? ( media-libs/libpng )"
DEPEND="${RDEPEND}
	x11-misc/xbitmaps
	x11-proto/printproto"

PROVIDE="virtual/motif"

pkg_setup() {
	# clean up orphaned cruft left over by motif-config
	local i l count=0
	for i in "${EROOT}"usr/bin/{mwm,uil,xmbind} \
		"${EROOT}"usr/include/{Xm,uil,Mrm} \
		"${EROOT}"usr/$(get_libdir)/lib{Xm,Uil,Mrm}.*; do
		[[ -L "${i}" ]] || continue
		l=$(readlink "${i}")
		if [[ ${l} == *openmotif-* || ${l} == *lesstif-* ]]; then
			einfo "Cleaning up orphaned ${i} symlink ..."
			rm -f "${i}"
		fi
	done

	cd "${EROOT}"usr/share/man
	for i in $(find . -type l); do
		l=$(readlink "${i}")
		if [[ ${l} == *-openmotif-* || ${l} == *-lesstif-* ]]; then
			(( count++ ))
			rm -f "${i}"
		fi
	done
	[[ ${count} -ne 0 ]] && \
		einfo "Cleaned up ${count} orphaned symlinks in ${EROOT}usr/share/man"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-sensitivity-invisible.patch"
	epatch "${FILESDIR}/${P}-fix-nedit-segfaults.patch"
	epatch "${FILESDIR}/${P}-freebsd-libiconv.patch"
	epatch "${FILESDIR}"/${P}-List.c-compile.patch

	cp "${FILESDIR}"/motif-config-2.3 "${T}"/
	pushd "${T}" > /dev/null
	epatch "${FILESDIR}"/motif-config-2.3-prefix.patch
	eprefixify motif-config-2.3
	popd > /dev/null

	# disable compilation of demo binaries
	sed -i -e '/^SUBDIRS/{:x;/\\$/{N;bx;};s/[ \t\n\\]*demos//;}' Makefile.am

	# add X.Org vendor string to aliases for virtual bindings
	echo -e '"The X.Org Foundation"\t\t\t\t\tpc' >>bindings/xmbind.alias

	AT_M4DIR=. eautoreconf
}

src_compile() {
	# get around some LANG problems in make (#15119)
	unset LANG

	# bug #80421
	filter-flags -ftracer

	# multilib includes don't work right in this package...
	has_multilib_profile && append-flags "-I$(get_ml_incdir)"

	# feel free to fix properly if you care
	append-flags -fno-strict-aliasing

	econf --with-x \
		--bindir="${EPREFIX}"/usr/$(get_libdir)/openmotif-${SLOT} \
		--libdir="${EPREFIX}"/usr/$(get_libdir)/openmotif-${SLOT} \
		$(use_enable xft) \
		$(use_enable jpeg) \
		$(use_enable png)

	emake -j1 || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	newbin "${T}"/motif-config-2.3 motif-config
	dosed "s:@@LIBDIR@@:$(get_libdir):g" /usr/bin/motif-config

	# mwm default configs
	insinto /usr/share/X11/app-defaults
	newins "${FILESDIR}"/Mwm.defaults Mwm

	dodir /etc/X11/mwm
	mv -f "${ED}"/usr/$(get_libdir)/X11/system.mwmrc "${ED}"/etc/X11/mwm
	dosym /etc/X11/mwm/system.mwmrc /usr/$(get_libdir)/X11/

	if use examples ; then
		emake -j1 -C demos DESTDIR="${D}" install-data \
			|| die "installation of demos failed"
		dodir /usr/share/doc/${PF}/demos
		mv "${ED}"/usr/share/Xm/* "${ED}"/usr/share/doc/${PF}/demos
	fi
	rm -rf "${ED}"/usr/share/Xm

	# documentation
	dodoc README RELEASE RELNOTES BUGREPORT TODO
	use doc && cp "${WORKDIR}"/*.pdf "${ED}"/usr/share/doc/${PF}
}

pkg_postinst() {
	"${EROOT}"/usr/bin/motif-config -s
}

pkg_postrm() {
	"${EROOT}"/usr/bin/motif-config -s
}

pkg_postinst() {
	local line
	while read line; do elog "${line}"; done <<-EOF
	Gentoo is no longer providing slotted Open Motif libraries.
	See bug 204249 and its dependencies for the reasons.

	From the Open Motif 2.3.0 (upstream) release notes:
	"Open Motif 2.3 is an updated version of 2.2. Any applications
	built against a previous 2.x release of Open Motif will be binary
	compatible with this release."

	If you have binary-only applications requiring libXm.so.3, you may
	therefore create a symlink from libXm.so.3 to libXm.so.4.
	Please note, however, that there will be no Gentoo support for this.
	Alternatively, you may install x11-libs/openmotif-compat-2.2* for
	the Open Motif 2.2 libraries.
	EOF
}
