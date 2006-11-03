# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/font.eclass,v 1.21 2006/10/30 06:13:48 dberkholz Exp $

# Author: foser <foser@gentoo.org>

# Font Eclass
#
# Eclass to make font installation uniform

inherit eutils

#
# Variable declarations
#

FONT_SUFFIX=""	# Space delimited list of font suffixes to install

FONT_S="${S}" # Dir containing the fonts

FONT_PN="${PN}" # Last part of $FONTDIR

FONTDIR="/usr/share/fonts/${FONT_PN}" # this is where the fonts are installed

DOCS="" # Docs to install

IUSE="X"

DEPEND="X? ( || ( x11-apps/mkfontdir virtual/x11 ) )
		media-libs/fontconfig"

#
# Public functions
#

font_xfont_config() {

	# create Xfont files
	if use X ; then
		einfo "Creating fonts.scale & fonts.dir ..."
		mkfontscale "${D}${FONTDIR}"
		mkfontdir \
			-e /usr/share/fonts/encodings \
			-e /usr/share/fonts/encodings/large \
			"${D}${FONTDIR}"
		if [ -e "${FONT_S}/fonts.alias" ] ; then
			doins "${FONT_S}/fonts.alias"
		fi
	fi

}

font_xft_config() {

	if ! has_version '>=media-libs/fontconfig-2.4'; then
		# create fontconfig cache
		einfo "Creating fontconfig cache ..."
		# Mac OS X has fc-cache at /usr/X11R6/bin
		HOME="/root" fc-cache -f "${D}${FONTDIR}"
	fi
}

#
# Public inheritable functions
#

font_src_install() {

	local suffix

	cd "${FONT_S}"

	insinto "${FONTDIR}"

	for suffix in ${FONT_SUFFIX}; do
		doins *.${suffix}
	done

	rm -f fonts.{dir,scale} encodings.dir

	font_xfont_config
	font_xft_config

	cd "${S}"
	# try to install some common docs
	DOCS="${DOCS} COPYRIGHT README NEWS"
	dodoc ${DOCS} 2> /dev/null

}

font_pkg_setup() {

	# make sure we get no colissions
	# setup is not the nicest place, but preinst doesn't cut it
	[[ -e "${FONTDIR}/fonts.cache-1" ]] && rm -f "${FONTDIR}/fonts.cache-1"

}

font_pkg_postinst() {

	if has_version '>=media-libs/fontconfig-2.4'; then
		if [ ${ROOT} == "/" ]; then
			ebegin "Updating global fontcache"
			fc-cache -s
			eend $?
		fi
	fi

}

font_pkg_postrm() {

	if has_version '>=media-libs/fontconfig-2.4'; then
		if [ ${ROOT} == "/" ]; then
			ebegin "Updating global fontcache"
			fc-cache -s
			eend $?
		fi
	fi

}

EXPORT_FUNCTIONS src_install pkg_setup pkg_postinst pkg_postrm
