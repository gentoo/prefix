# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mozilla.eclass,v 1.33 2007/03/26 20:19:22 genstef Exp $
#
# You probably don't want to change this eclass.  Newer ebuilds use
# mozconfig.eclass instead.


IUSE="java gnome gtk2 ldap debug xinerama xprint"
# Internal USE flags that I do not really want to advertise ...
IUSE="${IUSE} moznoxft"
[[ ${PN} == mozilla || ${PN} == mozilla-firefox ]] && \
	IUSE="${IUSE} mozdevelop mozxmlterm"
[[ ${PN} == mozilla ]] && \
	IUSE="${IUSE} mozsvg"

RDEPEND="
	!moznoxft? ( virtual/xft )
	>=media-libs/fontconfig-2.1
	>=sys-libs/zlib-1.1.4
	>=media-libs/jpeg-6b
	>=media-libs/libmng-1.0.0
	>=media-libs/libpng-1.2.1
	dev-libs/expat
	app-arch/zip
	app-arch/unzip
	gtk2? (
		>=x11-libs/gtk+-2.2.0
		>=dev-libs/glib-2.2.0
		>=x11-libs/pango-1.2.1
		>=dev-libs/libIDL-0.8.0
		gnome? ( >=gnome-base/gnome-vfs-2.3.5 ) )
	!gtk2? (
		=x11-libs/gtk+-1.2*
		=dev-libs/glib-1.2*
		=gnome-base/orbit-0* )
	>=www-client/mozilla-launcher-1.22"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

# Set by configure (plus USE_AUTOCONF=1), but useful for NSPR
export MOZILLA_CLIENT=1
export BUILD_OPT=1
export NO_STATIC_LIB=1
export USE_PTHREADS=1

mozilla_conf() {
	declare enable_optimize pango_version myext x
	declare MOZ=$([[ ${PN} == mozilla ]] && echo true || echo false)
	declare FF=$([[ ${PN} == *firefox ]] && echo true || echo false)
	declare TB=$([[ ${PN} == *thunderbird ]] && echo true || echo false)

	####################################
	#
	# CFLAGS setup and ARCH support
	#
	####################################

	# Set optimization level based on CFLAGS
	if is-flag -O0; then
		mozilla_annotate "from CFLAGS" --enable-optimize=-O0
	elif [[ ${ARCH} == hppa ]]; then
		mozconfig_annotate "more than -O0 causes segfaults on hppa" --enable-optimize=-O0
	elif [[ ${ARCH} == alpha || ${ARCH} == amd64 || ${ARCH} == ia64 || ${ARCH} == ppc64 ]]; then
		mozilla_annotate "more than -O1 causes segfaults on 64-bit (bug 33767)" \
			--enable-optimize=-O1
	elif is-flag -O1; then
		mozilla_annotate "from CFLAGS" --enable-optimize=-O1
	else
		mozilla_annotate "mozilla fallback" --enable-optimize=-O2
	fi

	# Now strip optimization from CFLAGS so it doesn't end up in the
	# compile string
	filter-flags '-O*'

	# Strip over-aggressive CFLAGS - Mozilla supplies its own
	# fine-tuned CFLAGS and shouldn't be interfered with..  Do this
	# AFTER setting optimization above since strip-flags only allows
	# -O -O1 and -O2
	strip-flags

	# Additional ARCH support
	case "${ARCH}" in
	alpha|amd64|ia64)
		# Historically we have needed to add this manually for 64-bit
		append-flags -fPIC
		;;

	ppc64)
		append-flags -mminimal-toc
		append-flags -fPIC
		;;

	ppc)
		# Fix to avoid gcc-3.3.x micompilation issues.
		if [[ $(gcc-major-version).$(gcc-minor-version) == 3.3 ]]; then
			append-flags -fno-strict-aliasing
		fi
		;;

	sparc)
		# Sparc support ...
		replace-sparc64-flags
		;;

	x86)
		if [[ $(gcc-major-version) -eq 3 ]]; then
			# gcc-3 prior to 3.2.3 doesn't work well for pentium4
			# see bug 25332
			if [[ $(gcc-minor-version) -lt 2 ||
				( $(gcc-minor-version) -eq 2 && $(gcc-micro-version) -lt 3 ) ]]
			then
				replace-flags -march=pentium4 -march=pentium3
				filter-flags -msse2
			fi
		fi
		;;
	esac

	if [[ $(gcc-major-version) -eq 3 ]]; then
		# Enable us to use flash, etc plugins compiled with gcc-2.95.3
		mozilla_annotate "building with >=gcc-3" --enable-old-abi-compat-wrappers

		# Needed to build without warnings on gcc-3
		CXXFLAGS="${CXXFLAGS} -Wno-deprecated"
	fi

	####################################
	#
	# myconf setup
	#
	####################################

	# myconf should be declared local by the caller (src_compile).
	myconf="${myconf} \
		--disable-activex \
		--disable-activex-scripting \
		--disable-installer \
		--disable-pedantic \
		--enable-crypto \
		--enable-xterm-updates \
		--with-pthreads \
		--with-system-jpeg \
		--with-system-png \
		--with-system-zlib \
		--with-x \
		--without-system-nspr \
		--enable-default-toolkit=gtk2 \
		$(mozilla_use_enable ipv6) \
		$(mozilla_use_enable xinerama) \
		$(mozilla_use_enable xprint) \
		$(mozilla_use_enable truetype freetype2) \
		$(mozilla_use_enable truetype freetypetest)"

	# NOTE: QT and XLIB toolkit seems very unstable, leave disabled until
	#       tested ok -- azarah
	if use gtk2; then
		mozilla_annotate +gtk2 --enable-default-toolkit=gtk2
		myconf="${myconf} $(mozilla_use_enable gnome gnomevfs)"
	else
		mozilla_annotate -gtk2 --enable-default-toolkit=gtk
		mozilla_annotate -gtk2 --disable-gnomevfs
	fi

	if use debug; then
		mozilla_annotate +debug \
			--enable-debug \
			--enable-tests \
			--disable-reorder \
			--disable-strip \
			--disable-strip-libs \
			--enable-debugger-info-modules=ALL_MODULES
	else
		mozilla_annotate -debug \
			--disable-debug \
			--disable-tests \
			--enable-reorder \
			--enable-strip \
			--enable-strip-libs

		# Currently --enable-elf-dynstr-gc only works for x86 and ppc,
		# thanks to Jason Wever <weeve@gentoo.org> for the fix.
		if use x86 || use ppc && [[ ${enable_optimize} != -O0 ]]; then
			mozilla_annotate "${ARCH} optimized build" --enable-elf-dynstr-gc
		fi
	fi

	# Here is a strange one...
	if is-flag '-mcpu=ultrasparc*'; then
		mozilla_annotate "building on ultrasparc" --enable-js-ultrasparc
	fi

	# Check if we should enable Xft support...
	if use moznoxft; then
		mozilla_annotate "disabling xft2 by request (+moznoxft)" --disable-xft
	elif use gtk2; then
		# We need Xft2.0 locally installed
		if [[ -x /usr/bin/pkg-config ]] && pkg-config xft; then
			# We also need pango-1.1, else Mozilla links to both
			# Xft1.1 *and* Xft2.0, and segfault...
			pango_version=$(pkg-config --modversion pango | cut -d. -f1,2)
			if [[ ${pango_version//.} -gt 10 ]]; then
				mozilla_annotate "gtk2 with xft2 (+gtk2 -moznoxft)" --enable-xft
			else
				mozilla_annotate "gtk2 without xft2 (bad pango version <1.1)" --disable-xft
			fi
		else
			mozilla_annotate "gtk2 without xft2 (no pkg-config xft)" --disable-xft
		fi
	else
		mozilla_annotate "gtk1 with xft2 (-gtk2 -moznoxft)" --enable-xft
	fi

	# Support some development/debugging stuff for web developers
	if ( ${MOZ} || ${FF} ) && use mozdevelop; then
		mozilla_annotate "+mozdevelop on ${PN}" \
			--enable-jsd \
			--enable-xpctools
	else
		mozilla_annotate "n/a on ${PN}" \
			--disable-jsd \
			--disable-xpctools
	fi

	# Some browser-only flags
	if ${MOZ} || ${FF}; then
		# Bug 60668: Galeon doesn't build without oji enabled, so enable it
		# regardless of java setting.
		myconf="${myconf} --enable-oji \
			--enable-mathml"
	else
		mozilla_annotate "n/a on ${PN}" --disable-oji
	fi

	# Some mailer-only flags
	if ${TB}; then
		# Set up extensions
		if [[ ${PV} < 0.8 ]]; then
			myext="pref,spellcheck,universalchardet,wallet"
		else
			myext="wallet,spellcheck,xmlextras,webservices"
		fi

		myconf="${myconf} --enable-single-profile \
			--enable-necko-protocols=http,file,jar,viewsource,res,data \
			--enable-image-decoders=default,-xbm \
			$(mozilla_use_enable ldap) \
			$(mozilla_use_enable ldap ldap-experimental) \
			--enable-extensions=${myext}"

		mozilla_annotate "n/a on ${PN}" \
			--disable-calendar \
			--disable-svg \
			--disable-necko-disk-cache \
			--disable-profilesharing \
			--disable-plugins
	fi

	# Some firefox-only flags
	if ${FF}; then
		# Set up extensions
		myext="cookie,inspector,negotiateauth,pref,transformiix,universalchardet,webservices,xmlextras,xml-rpc"
		[[ ${PV} < 1.0 ]] && myext="${myext},typeaheadfind"
		use mozdevelop && myext="${myext},venkman"
		use gnome && use gtk2 && myext="${myext},gnomevfs"

		myconf="${myconf} \
			--enable-single-profile \
			--enable-extensions=${myext}"

		mozilla_annotate "n/a on ${PN}" \
			--disable-mailnews \
			--disable-composer \
			--disable-ldap \
			--disable-profilesharing
	fi

	# Some moz-only flags
	if ${MOZ}; then
		# Set up extensions
		myext="default"
		use mozdevelop && myext="${myext},venkman"
		use gnome && myext="${myext},gnomevfs"
		use moznoirc && myext="${myext},-irc"
		use mozxmlterm && myext="${myext},xmlterm"

		myconf="${myconf} \
			$(mozilla_use_enable mozcalendar calendar) \
			$(mozilla_use_enable ldap) \
			$(mozilla_use_enable ldap ldap-experimental) \
			--enable-extensions=${myext}"

		if use moznomail && ! use mozcalendar; then
			mozilla_annotate "+moznomail -mozcalendar" --disable-mailnews
		fi
		if use moznocompose && use moznomail; then
			mozilla_annotate "+moznocompose +moznomail" --disable-composer
		fi
		# Re-enabled per bug 24522 (28 Apr 2004 agriffis)
		if use mozsvg; then
			export MOZ_INTERNAL_LIBART_LGPL=1
			mozilla_annotate "+mozsvg on ${PN}" \
				--enable-svg --enable-svg-renderer-libart
		else
			mozilla_annotate "-mozsvg" \
				--disable-svg
		fi
	fi

	# Report!
	echo
	echo "=========================================================="
	echo "Building ${PF} with the following configuration"
	for x in $(echo ${myconf} | sed 's/ /\n/g' | sort); do
		mozilla_explain "${x}"
	done
	echo "=========================================================="
	echo
}

# Simulate the silly csh makemake script
makemake() {
	typeset m topdir
	for m in $(find . -name Makefile.in); do
		topdir=$(echo "$m" | sed -r 's:[^/]+:..:g')
		sed -e "s:@srcdir@:.:g" -e "s:@top_srcdir@:${topdir}:g" \
			< ${m} > ${m%.in} || die "sed ${m} failed"
	done
}

#
# The following functions are internal to mozilla.eclass
#

mozilla_use_enable() {
	declare flag=$(use_enable "$@")
	mozilla_annotate "$(useq ${1} && echo +${1} || echo -${1})" "${flag}"
	echo "${flag}"
}

mozilla_annotate() {
	declare reason=${1} x ; shift
	[[ $# -gt 0 ]] || die "mozilla_annotate missing flags for ${reason}!"
	mkdir -p ${T}/annotations
	for x in ${*}; do
		myconf="${myconf} ${x}"
		echo "${reason}" > "${T}/annotations/${x%%=*}"
	done
}

mozilla_explain() {
	printf "    %-30s  %s\n" "${1}" "$(cat "${T}/annotations/${1%%=*}" 2>/dev/null)"
}
