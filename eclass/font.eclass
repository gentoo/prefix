# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/font.eclass,v 1.38 2008/06/21 06:12:45 pva Exp $

# @ECLASS: font.eclass
# @MAINTAINER:
# fonts@gentoo.org
#
# Author: foser <foser@gentoo.org>
# @BLURB: Eclass to make font installation uniform

inherit eutils

#
# Variable declarations
#

# @ECLASS-VARIABLE: FONT_SUFFIX
# @DESCRIPTION:
# Space delimited list of font suffixes to install
FONT_SUFFIX=""

# @ECLASS-VARIABLE: FONT_S
# @DESCRIPTION:
# Dir containing the fonts
FONT_S=${S} 

# @ECLASS-VARIABLE: FONT_PN
# @DESCRIPTION:
# Last part of $FONTDIR
FONT_PN=${PN} 

# @ECLASS-VARIABLE: FONTDIR
# @DESCRIPTION:
# This is where the fonts are installed
FONTDIR=/usr/share/fonts/${FONT_PN} 

# @ECLASS-VARIABLE: FONT_CONF
# @DESCRIPTION:
# Array, which element(s) is(are) path(s) of fontconfig-2.4 file(s) to install
FONT_CONF=( "" )  

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Docs to install
DOCS="" 

IUSE="X"

DEPEND="X? ( x11-apps/mkfontdir )
		media-libs/fontconfig"

#
# Public functions
#

# @FUNCTION: font_xfont_config
# @DESCRIPTION:
# Creates the Xfont files.
font_xfont_config() {
	# create Xfont files
	if use X ; then
		einfo "Creating fonts.scale & fonts.dir ..."
		mkfontscale "${ED}${FONTDIR}"
		mkfontdir \
			-e "${EPREFIX}"/usr/share/fonts/encodings \
			-e "${EPREFIX}"/usr/share/fonts/encodings/large \
			"${ED}${FONTDIR}"
		if [ -e "${FONT_S}/fonts.alias" ] ; then
			doins "${FONT_S}/fonts.alias"
		fi
	fi
}

# @FUNCTION: font_xft_config
# @DESCRIPTION:
# Creates the fontconfig cache if necessary.
font_xft_config() {
	if ! has_version '>=media-libs/fontconfig-2.4'; then
		# create fontconfig cache
		einfo "Creating fontconfig cache ..."
		# Mac OS X has fc-cache at /usr/X11R6/bin
		# HOME was /root
		HOME="${T}" fc-cache -f "${ED}${FONTDIR}"
	fi
}

# @FUNCTION: font_fontconfig
# @DESCRIPTION:
# Installs the fontconfig config files of FONT_CONF.
font_fontconfig() {
	local conffile
	if [[ -n ${FONT_CONF[@]} ]]; then
		if has_version '>=media-libs/fontconfig-2.4'; then
			insinto /etc/fonts/conf.avail/
			for conffile in "${FONT_CONF[@]}"; do
				[[ -e  ${conffile} ]] && doins ${conffile}
			done
		fi
	fi
}

#
# Public inheritable functions
#

# @FUNCTION: font_src_install
# @DESCRIPTION:
# The font src_install function, which is exported.
font_src_install() {
	local suffix commondoc

	cd "${FONT_S}"

	insinto "${FONTDIR}"

	for suffix in ${FONT_SUFFIX}; do
		doins *.${suffix}
	done

	rm -f fonts.{dir,scale} encodings.dir

	font_xfont_config
	font_xft_config
	font_fontconfig

	cd "${S}"
	dodoc ${DOCS} 2> /dev/null

	# install common docs
	for commondoc in COPYRIGHT README{,.txt} NEWS AUTHORS BUGS ChangeLog FONTLOG.txt; do
		[[ -s ${commondoc} ]] && dodoc ${commondoc}
	done
}

# @FUNCTION: font_pkg_setup
# @DESCRIPTION:
# The font pkg_setup function, which is exported.
font_pkg_setup() {
	# make sure we get no collisions
	# setup is not the nicest place, but preinst doesn't cut it
	[[ -e "${EPREFIX}${FONTDIR}/fonts.cache-1" ]] && rm -f "${EPREFIX}${FONTDIR}/fonts.cache-1"
}

# @FUNCTION: font_pkg_postinst
# @DESCRIPTION:
# The font pkg_postinst function, which is exported.
font_pkg_postinst() {
	# unreadable font files = fontconfig segfaults
	find "${EROOT}"usr/share/fonts/ -type f '!' -perm 0644 -print0 \
		| xargs -0 chmod -v 0644 2>/dev/null

	if has_version '>=media-libs/fontconfig-2.4'; then
		if [ ${ROOT} == "/" ]; then
			ebegin "Updating global fontcache"
			fc-cache -fs
			eend $?
		fi
	fi
}

# @FUNCTION: font_pkg_postrm
# @DESCRIPTION:
# The font pkg_postrm function, which is exported.
font_pkg_postrm() {
	# unreadable font files = fontconfig segfaults
	find "${EROOT}"usr/share/fonts/ -type f '!' -perm 0644 -print0 \
		| xargs -0 chmod -v 0644 2>/dev/null

	if has_version '>=media-libs/fontconfig-2.4'; then
		if [ ${ROOT} == "/" ]; then
			ebegin "Updating global fontcache"
			fc-cache -fs
			eend $?
		fi
	fi
}

EXPORT_FUNCTIONS src_install pkg_setup pkg_postinst pkg_postrm
