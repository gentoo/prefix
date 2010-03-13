# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.0.1-r1.ebuild,v 1.8 2010/02/11 15:15:14 ulm Exp $

EAPI=2

inherit linux-info base eutils flag-o-matic multilib

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"
SRC_URI="ftp://ftp.novell.com/pub/mono/sources/mono/${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 MIT )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="minimal"

RDEPEND="!<dev-dotnet/pnet-0.6.12
		dev-libs/glib:2
		!minimal? ( =dev-dotnet/libgdiplus-${PV%.*}* )
	ia64? ( sys-libs/libunwind )"

DEPEND="${RDEPEND}
		sys-devel/bc
		>=dev-util/pkgconfig-0.19"
PDEPEND="dev-dotnet/pe-format"

RESTRICT="test"

#Threading and mimeicon patches from Fedora CVS. Muine patch from Novell. Pointer conversions patch from Debian.

PATCHES=(	"${FILESDIR}/${PN}-biginteger_overflow.diff"
		"${FILESDIR}/${PN}-2.0-ppc-threading.patch"
		"${FILESDIR}/${PN}-2.0-mimeicon.patch"
		"${FILESDIR}/${P}-fix-wsdl-troubles-with-muine.patch"
		"${FILESDIR}/${P}-fix_implicit_pointer_conversions.patch"
		"${FILESDIR}/${PN}-2.0-fix-headless.patch" )

pkg_setup() {
	if use kernel_linux
	then
		get_version
		if linux_config_exists
		then
			if linux_chkconfig_present SYSVIPC
			then
				einfo "CONFIG_SYSVIPC is set, looking good."
			else
				eerror "If CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling."
				eerror "See http://bugs.gentoo.org/261869 for more info."
				die "Please set CONFIG_SYSVIPC in your kernel .config"
			fi
		else
			ewarn "Was unable to determine your kernel .config"
			ewarn "Please note that if CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling."
			ewarn "See http://bugs.gentoo.org/261869 for more info."
		fi
	fi
}

src_configure() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	econf	--disable-dependency-tracking \
		--without-moonlight \
		--with-preview=yes \
		--with-glib=system \
		--with-gc=included \
		--with-libgdiplus=$( use !minimal && printf "installed" || printf "no" ) \
		--with-ikvm-native=no \
		--with-jit=yes

	# dev-dotnet/ikvm provides ikvm-native
}

src_compile() {
	emake -j1 EXTERNAL_MCS=false EXTERNAL_MONO=false

	if [[ "$?" -ne "0" ]]; then
		ewarn "If you are using any hardening features such as"
		ewarn "PIE+SSP/SELinux/grsec/PAX then most probably this is the reason"
		ewarn "why build has failed. In this case turn any active security"
		ewarn "enhancements off and try emerging the package again"
		die
	fi
}

src_test() {
	echo ">>> Test phase [check]: ${CATEGORY}/${PF}"

	mkdir -p "${T}/home/mono" || die "mkdir home failed"

	export HOME="${T}/home/mono"
	export XDG_CONFIG_HOME="${T}/home/mono"
	export XDG_DATA_HOME="${T}/home/mono"

	if ! LC_ALL=C emake -j1 check; then
		hasq test $FEATURES && die "Make check failed. See above for details."
		hasq test $FEATURES || eerror "Make check failed. See above for details."
	fi
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog
}
