# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-firefox/mozilla-firefox-2.0.0.4.ebuild,v 1.1 2007/05/31 10:49:30 armin76 Exp $

EAPI="prefix"

WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-2 mozilla-launcher makeedit multilib fdo-mime mozextension autotools

PATCH="${P}-patches-0.1"
LANGS="af ar be bg ca cs da de el en-GB es-AR es-ES eu fi fr fy-NL ga-IE gu-IN he hu it ja ka ko ku lt mk mn nb-NO nl nn-NO pa-IN pl pt-BR pt-PT ro ru sk sl sv-SE tr zh-CN zh-TW"
NOSHORTLANGS="en-GB es-AR pt-BR zh-TW"

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="http://www.mozilla.org/projects/firefox/"

KEYWORDS="~amd64 ~ia64 ~mips ~x86"
SLOT="0"
LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
IUSE="java mozdevelop bindist xforms restrict-javascript filepicker"

MOZ_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${PV}"
SRC_URI="${MOZ_URI}/source/firefox-${PV}-source.tar.bz2
	mirror://gentoo/${PATCH}.tar.bz2"

# These are in
#
#  http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${PV}/linux-i686/xpi/
#
# for i in $LANGS $SHORTLANGS; do wget $i.xpi -O ${P}-$i.xpi; done
for X in ${LANGS} ; do
	SRC_URI="${SRC_URI}
		linguas_${X/-/_}? ( http://dev.gentooexperimental.org/~armin76/dist/${P}-xpi/${P}-${X}.xpi )"
	IUSE="${IUSE} linguas_${X/-/_}"
	# english is handled internally
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
		SRC_URI="${SRC_URI}
			linguas_${X%%-*}? ( http://dev.gentooexperimental.org/~armin76/dist/${P}-xpi/${P}-${X}.xpi )"
		IUSE="${IUSE} linguas_${X%%-*}"
	fi
done

RDEPEND="java? ( virtual/jre )
	>=www-client/mozilla-launcher-1.39
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.11.5
	>=dev-libs/nspr-4.6.5"

DEPEND="${RDEPEND}
	java? ( >=dev-java/java-config-0.2.0 )"

PDEPEND="restrict-javascript? ( x11-plugins/noscript )"

S="${WORKDIR}/mozilla"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=browser
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

linguas() {
	local LANG SLANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} en en_US; then
			has en ${linguas} || linguas="${linguas:+"${linguas} "}en"
			continue
		elif has ${LANG} ${LANGS//-/_}; then
			has ${LANG//_/-} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG//_/-}"
			continue
		elif [[ " ${LANGS} " == *" ${LANG}-"* ]]; then
			for X in ${LANGS}; do
				if [[ "${X}" == "${LANG}-"* ]] && \
					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but mozilla-firefox does not support the ${LANG} LINGUA"
	done
	elog "Selected language packs (first will be default): $linguas"
}

pkg_setup(){
	if ! built_with_use x11-libs/cairo X; then
		eerror "Cairo is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge cairo."
		die "Cairo needs X"
	fi

	if ! use bindist; then
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with mozilla foundation"
	fi

	use moznopango && warn_mozilla_launcher_stub
}

src_unpack() {
	unpack firefox-${PV}-source.tar.bz2  ${PATCH}.tar.bz2

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_unpack "${P}-${X}.xpi"
	done

	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"/patch

	if use filepicker; then
		epatch ${FILESDIR}/mozilla-filepicker.patch
	fi

	eautoreconf
}

src_compile() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	mozconfig_init
	mozconfig_config

	mozconfig_annotate '' --enable-application=browser
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss

	if use xforms; then
		mozconfig_annotate '' --enable-extensions=default,xforms,schema-validation,typeaheadfind
	else
		mozconfig_annotate '' --enable-extensions=default,typeaheadfind
	fi

	if use ia64; then
		echo "ac_cv_visibility_pragma=no" >>  "${S}/.mozconfig"
	fi

	if ! use bindist; then
		mozconfig_annotate '' --enable-official-branding
	fi

	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml

	# Other ff-specific settings
	mozconfig_use_enable mozdevelop jsd
	mozconfig_use_enable mozdevelop xpctools
	mozconfig_use_extension mozdevelop venkman
	mozconfig_annotate '' --with-default-mozilla-five-home="${EPREFIX}"${MOZILLA_FIVE_HOME}

	# Finalize and report settings
	mozconfig_final

	# -fstack-protector breaks us
	if gcc-version ge 4 1; then
		gcc-specs-ssp && append-flags -fno-stack-protector
	else
		gcc-specs-ssp && append-flags -fno-stack-protector-all
	fi
		filter-flags -fstack-protector -fstack-protector-all

	####################################
	#
	#  Configure and build
	#
	####################################

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"'"${EPREFIX}"'/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"'"${EPREFIX}"'/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		${S}/config/autoconf.mk \
		${S}/xpfe/global/buildconfig.html

	# This removes extraneous CFLAGS from the Makefiles to reduce RAM
	# requirements while compiling
	edit_makefiles

	emake -j1 || die
}

pkg_preinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	elog "Removing old installs though some really ugly code.  It potentially"
	elog "eliminates any problems during the install, however suggestions to"
	elog "replace this are highly welcome.  Send comments and suggestions to"
	elog "mozilla@gentoo.org."
	rm -rf "${EROOT}"/"${MOZILLA_FIVE_HOME}"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# Most of the installation happens here
	dodir "${MOZILLA_FIVE_HOME}"
	cp -RL "${S}"/dist/bin/* "${ED}"/"${MOZILLA_FIVE_HOME}"/ || die "cp failed"

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_install "${WORKDIR}"/"${P}-${X}"
	done

	local LANG=${linguas%% *}
	if [[ -n ${LANG} && ${LANG} != "en" ]]; then
		elog "Setting default locale to ${LANG}"
		dosed -e "s:general.useragent.locale\", \"en-US\":general.useragent.locale\", \"${LANG}\":" \
			"${MOZILLA_FIVE_HOME}"/defaults/pref/firefox.js \
			"${MOZILLA_FIVE_HOME}"/defaults/pref/firefox-l10n.js || \
			die "sed failed to change locale"
	fi

	# Create /usr/bin/firefox
	install_mozilla_launcher_stub firefox "${MOZILLA_FIVE_HOME}"

	# Install icon and .desktop for menu entry
	if ! use bindist; then
		doicon "${FILESDIR}"/icon/firefox-icon.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5.desktop \
			mozilla-firefox-2.0.desktop
	else
		doicon "${FILESDIR}"/icon/firefox-icon-unbranded.png
		newmenu "${FILESDIR}"/icon/mozilla-firefox-1.5-unbranded.desktop \
			mozilla-firefox-2.0.desktop
	fi

	# Fix icons to look the same everywhere
	insinto "${MOZILLA_FIVE_HOME}"/icons
	doins "${S}"/dist/branding/mozicon16.xpm
	doins "${S}"/dist/branding/mozicon50.xpm

	# Install files necessary for applications to build against firefox
	elog "Installing includes and idl files..."
	cp -LfR "${S}"/dist/include "${ED}"/"${MOZILLA_FIVE_HOME}" || die "cp failed"
	cp -LfR "${S}"/dist/idl "${ED}"/"${MOZILLA_FIVE_HOME}" || die "cp failed"

	# Dirty hack to get some applications using this header running
	dosym "${MOZILLA_FIVE_HOME}"/include/necko/nsIURI.h \
		"${MOZILLA_FIVE_HOME}"/include/nsIURI.h

	# Install pkgconfig files
	insinto /usr/"$(get_libdir)"/pkgconfig
	doins "${S}"/build/unix/*.pc

	insinto "${MOZILLA_FIVE_HOME}"/greprefs
	newins "${FILESDIR}"/gentoo-default-prefs.js all-gentoo.js
	insinto "${MOZILLA_FIVE_HOME}"/defaults/pref
	newins "${FILESDIR}"/gentoo-default-prefs.js all-gentoo.js
}

pkg_postinst() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	# This should be called in the postinst and postrm of all the
	# mozilla, mozilla-bin, firefox, firefox-bin, thunderbird and
	# thunderbird-bin ebuilds.
	update_mozilla_launcher_symlinks

	# Update mimedb for the new .desktop file
	fdo-mime_desktop_database_update

	elog "Please remember to rebuild any packages that you have built"
	elog "against firefox. Some packages might be broken by the upgrade; if this"
	elog "is the case, please search at http://bugs.gentoo.org and open a new bug"
	elog "if one does not exist. Before filing any bugs, please move or remove ~/.mozilla"
	elog "and test with a clean profile directory."
}

pkg_postrm() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}"

	update_mozilla_launcher_symlinks
}
