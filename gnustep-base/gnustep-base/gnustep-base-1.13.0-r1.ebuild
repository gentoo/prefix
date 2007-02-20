# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-base/gnustep-base-1.13.0-r1.ebuild,v 1.1 2006/12/05 19:51:34 grobian Exp $

EAPI="prefix"

inherit gnustep autotools

DESCRIPTION="The GNUstep Base Library is a library of general-purpose, non-graphical Objective C objects."

HOMEPAGE="http://www.gnustep.org"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/${P}.tar.gz"
KEYWORDS="~amd64 ~ppc-macos"
SLOT="0"
LICENSE="GPL-2 LGPL-2.1"

IUSE="${IUSE} doc gcc-libffi"

DEPEND="${GNUSTEP_CORE_DEPEND}
	~gnustep-base/gnustep-make-1.13.0
	|| (
		dev-libs/ffcall
		gcc-libffi? ( >=sys-devel/gcc-3.3.5 )
	)
	>=dev-libs/libxml2-2.6
	>=dev-libs/libxslt-1.1
	>=dev-libs/gmp-4.1
	>=dev-libs/openssl-0.9.7
	>=sys-libs/zlib-1.2
	sys-apps/sed
	${DOC_DEPEND}"
RDEPEND="${DEPEND}
	${DEBUG_DEPEND}
	${DOC_RDEPEND}"

egnustep_install_domain "System"

pkg_setup() {
	if use gcc-libffi; then
		export OBJC_INCLUDE_PATH="OBJC_INCLUDE_PATH:$(gcc-config -L | sed 's/:.*//')/include/libffi"
		if [ "$(ffi_available)" == "no" ]; then
			ffi_not_available_info
			die "libffi is not available"
		fi
	fi
}

src_unpack() {
	egnustep_env
	unpack ${A}
	# TODO: need for obey-homedir patch?

	cd ${S}

	# FIX non-flattened
	if [ -z $GNUSTEP_FLATTENED ];
	then
		sed -i -e 's:$GNUSTEP_MAKEFILES/config.make:$GNUSTEP_MAKEFILES/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO/config.make:' \
			-e 's:$GNUSTEP_MAKEFILES/$obj_dir/config.make:$GNUSTEP_MAKEFILES/$obj_dir/$LIBRARY_COMBO/config.make:' \
			configure.ac
		eautoreconf
	fi
}

src_compile() {
	egnustep_env
	# why libffi over ffcall?
	# - libffi is known to work with 32 and 64 bit platforms
	# - libffi does not use trampolines
	# but upstream seems to prefer ffcall
	local myconf
	if use gcc-libffi;
	then
		myconf="--enable-libffi --disable-ffcall"
		myconf="${myconf} --with-ffi-library=$(gcc-config -L) --with-ffi-include=$(gcc-config -L | sed 's/:.*//')/include/libffi"
	else
		myconf="--disable-libffi --enable-ffcall"
	fi

	myconf="$myconf --with-xml-prefix=${EPREFIX}/usr"
	myconf="$myconf --with-gmp-include=${EPREFIX}/usr/include --with-gmp-library=${EPREFIX}/usr/lib"
	myconf="$myconf --with-default-config=${EPREFIX}/etc/GNUstep/GNUstep.conf"

	econf $myconf || die "configure failed"

	egnustep_make || die
}

src_install() {
	egnustep_env
	egnustep_install || die

	local base_temp_lib_path
	if [ ! -z $GNUSTEP_FLATTENED ]; then
		base_temp_lib_path="$(egnustep_install_domain)/Library/Libraries"
	else
		base_temp_lib_path="$(egnustep_install_domain)/Library/Libraries/$GNUSTEP_HOST_CPU/$GNUSTEP_HOST_OS/$LIBRARY_COMBO"
	fi

	if use doc;
	then
		local make_eval="INSTALL_ROOT=\${ED} \
			GNUSTEP_SYSTEM_ROOT=\${ED}\$(egnustep_system_root) \
			GNUSTEP_NETWORK_ROOT=\$(egnustep_network_root) \
			GNUSTEP_LOCAL_ROOT=\$(egnustep_local_root) \
			GNUSTEP_MAKEFILES=\$(egnustep_system_root)/Library/Makefiles \
			GNUSTEP_USER_ROOT=\${TMP} \
			GNUSTEP_DEFAULTS_ROOT=\${TMP}/\${__GS_USER_ROOT_POSTFIX} \
			LD_LIBRARY_PATH=\"\${ED}\${base_temp_lib_path}:\${LD_LIBRARY_PATH}\" \
			GNUSTEP_INSTALLATION_DIR=\${ED}\$(egnustep_install_domain) \
			-j1"
		use debug && make_eval="${make_eval} debug=yes"
		use verbose && make_eval="${make_eval} verbose=yes"

		cd ${S}/Documentation
		eval emake ${make_eval} AUTOGSDOC="${S}/Tools/obj/autogsdoc" all \
			|| die "doc make has failed"
		eval emake ${make_eval} install \
			|| die "doc install has failed"
		cd ..
	fi

	newinitd "${FILESDIR}"/gnustep.initd-${PV} gnustep

	dodir /etc/revdep-rebuild
	sed -e 's|$GNUSTEP_SEARCH_DIRS|'"$GNUSTEP_PATHLIST"'|' \
		"${FILESDIR}"/50-gnustep-revdep \
		> "${ED}/etc/revdep-rebuild/50-gnustep-revdep"

	egnustep_package_config
}

pkg_postinst() {
	egnustep_env

	ewarn "The shared library version has changed in this release."
	ewarn "You will need to recompile all Applications/Tools/etc in order"
	ewarn "to use this library."
	ewarn "Run:"
	ewarn "revdep-rebuild --library \"libgnustep-base.so.1.1[012]\""
}
