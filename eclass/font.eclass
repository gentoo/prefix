# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/font.eclass,v 1.37 2008/05/19 00:42:13 dirtyepic Exp $

# Author: foser <foser@gentoo.org>

# Font Eclass
#
# Eclass to make font installation uniform

inherit eutils

#
# Variable declarations
#

FONT_SUFFIX=""	# Space delimited list of font suffixes to install

FONT_S=${S} # Dir containing the fonts

FONT_PN=${PN} # Last part of $FONTDIR

FONTDIR=/usr/share/fonts/${FONT_PN} # This is where the fonts are installed

FONT_CONF=( "" )  # Array, which element(s) is(are) path(s) of fontconfig-2.4 file(s) to install

DOCS="" # Docs to install

IUSE="X"

DEPEND="X? ( x11-apps/mkfontdir )
		media-libs/fontconfig"

#
# Public functions
#

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

font_xft_config() {
	if ! has_version '>=media-libs/fontconfig-2.4'; then
		# create fontconfig cache
		einfo "Creating fontconfig cache ..."
		# Mac OS X has fc-cache at /usr/X11R6/bin
		# HOME was /root
		HOME="${T}" fc-cache -f "${ED}${FONTDIR}"
	fi
}

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

font_pkg_setup() {
	# make sure we get no collisions
	# setup is not the nicest place, but preinst doesn't cut it
	[[ -e "${EPREFIX}${FONTDIR}/fonts.cache-1" ]] && rm -f "${EPREFIX}${FONTDIR}/fonts.cache-1"
}

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
