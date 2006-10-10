# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gst-plugins.eclass,v 1.33 2006/09/01 16:46:28 zaheerm Exp $

# Author : foser <foser@gentoo.org>

# gst-plugins eclass
#
# eclass to make external gst-plugins emergable on a per-plugin basis
# to solve the problem with gst-plugins generating far too much unneeded deps
#
# 3rd party applications using gstreamer now should depend on a set of plugins as
# defined in the source, in case of spider usage obtain recommended plugins to use from
# Gentoo developers responsible for gstreamer <gnome@gentoo.org>, the application developer
# or the gstreamer team.

inherit eutils libtool autotools


###
# variable declarations
###

# Create a major/minor combo for our SLOT and executables suffix
PVP=(${PV//[-\._]/ })
PV_MAJ_MIN=${PVP[0]}.${PVP[1]}

MY_P=gst-plugins-${PV}

# All relevant configure options for gst-plugins
# need a better way to extract these
# gstreamer 0.6
my_gst_plugins="dxr3 oss qcam v4l v4l2 vcd vga cdrom xvideo a52dec aalib aalibtest alsa arts artstest artsc audiofile avifile cdparanoia dvdread dvdnav esd esdtest flac ffmpeg gnome_vfs gsm hermes http jack jpeg ladspa lame lcs libdv libfame libfametest libpng mad mikmod libmikmodtest mjpegtools mpeg2dec openquicktime raw1394 rtp sdl sdltest shout shout2 shout2test sidplay smoothwave snapshot swfdec tarkin vorbis vorbistest xmms libmmx atomic tests examples"
# gstreamer 0.8
my_gst_plugins="${my_gst_plugins} divx faad gdk_pixbuf ogg sndfile x pango speex xvid mpeg2enc mplex musicbrainz nas librfb libcaca ivorbis faac theora kio osx_audio osx_video sunaudio artsc dts libvisual dirac libmng opengl gst_v4l gst_v4l2 libmms musepack directfb polyp cairo spc wavpack cdio amrnb x264 raw1394"

# Extract the plugin to build from the ebuild name
# May be set by an ebuild and contain more than one indentifier, space seperated
# (only src_configure can handle mutiple plugins at this time)
GST_PLUGINS_BUILD=${PN/gst-plugins-/}

# Actual build dir, is the same as the configure switch name most of the time
GST_PLUGINS_BUILD_DIR=${PN/gst-plugins-/}

# general common gst-plugins ebuild entries
DESCRIPTION="${BUILD_GST_PLUGINS} plugin for gstreamer"
HOMEPAGE="http://gstreamer.freedesktop.org/modules/gst-plugins.html"
LICENSE="GPL-2"

SRC_URI="mirror://gnome/sources/gst-plugins/${PV_MAJ_MIN}/${MY_P}.tar.bz2"
SLOT=${PV_MAJ_MIN}

S=${WORKDIR}/${MY_P}

# added to remove circular deps
# 6/2/2006 - zaheerm
if [ "${P}" != "${MY_P}" ]; then
RDEPEND="=media-libs/${MY_P}*"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-apps/sed-4"
fi

###
# internal functions
###

gst-plugins_find_plugin_dir() {

	if [ ! -d ${S}/ext/${GST_PLUGINS_BUILD_DIR} ]; then
		if [ ! -d ${S}/sys/${GST_PLUGINS_BUILD_DIR} ]; then
			ewarn "No such plugin directory"
			die
		fi
		einfo "Building system plugin ..."
		cd ${S}/sys/${GST_PLUGINS_BUILD_DIR}
	else
		einfo "Building external plugin ..."
		cd ${S}/ext/${GST_PLUGINS_BUILD_DIR}
	fi

}

###
# public functions
###

gst-plugins_src_configure() {

	# disable any external plugin besides the plugin we want
	local plugin gst_conf

	einfo "Configuring to build ${GST_PLUGINS_BUILD} plugin(s) ..."

	for plugin in ${GST_PLUGINS_BUILD}; do
		my_gst_plugins=${my_gst_plugins/${plugin}/}
	done
	for plugin in ${my_gst_plugins}; do
		gst_conf="${gst_conf} --disable-${plugin} "
	done
	for plugin in ${GST_PLUGINS_BUILD}; do
		gst_conf="${gst_conf} --enable-${plugin} "
	done

	cd ${S}
	econf ${@} ${gst_conf} || die "./configure failure"

}

gst-plugins_update_registry() {

	einfo "Updating gstreamer plugins registry for gstreamer ${SLOT} ..."
	gst-register-${SLOT}

}

gst-plugins_remove_unversioned_binaries() {

	# remove the unversioned binaries gstreamer provide
	# this is to prevent these binaries to be owned by several SLOTs

	cd ${D}/usr/bin
	for gst_bins in `ls *-${PV_MAJ_MIN}`
	do
		rm ${gst_bins/-${PV_MAJ_MIN}/}
		einfo "Removed ${gst_bins/-${PV_MAJ_MIN}/}"
	done

}

###
# public inheritable functions
###

gst-plugins_src_unpack() {

	local makefiles

	unpack ${A}

	# apply patch to fix broken configure in 0.8.11
	cd ${S}
	if [ ${PV} == "0.8.11" ]; then
		epatch ${FILESDIR}/../../../media-libs/gst-plugins/files/gst-plugins-0.8.11-conffix.patch
		AT_M4DIR="-I m4 -I common/m4"
		eautoreconf
		elibtoolize
	fi

	# Link with the syswide installed interfaces if needed
	gst-plugins_find_plugin_dir
	sed -e "s:\$(top_builddir)/gst-libs/gst/libgstinterfaces:/usr/$(get_libdir)/libgstinterfaces:" \
		-e "s:\${top_builddir}/gst-libs/gst/libgstinterfaces:/usr/$(get_libdir)/libgstinterfaces:" \
		-i Makefile.in
	cd ${S}

	# Remove generation of any other Makefiles except the plugin's Makefile
	if [ -d "${S}/sys/${GST_PLUGINS_BUILD_DIR}" ]; then
		makefiles="Makefile sys/Makefile sys/${GST_PLUGINS_BUILD_DIR}/Makefile"
	elif [ -d "${S}/ext/${GST_PLUGINS_BUILD_DIR}" ]; then
		makefiles="Makefile ext/Makefile ext/${GST_PLUGINS_BUILD_DIR}/Makefile"
	fi
	sed -e "s:ac_config_files=.*:ac_config_files='${makefiles}':" \
		-i ${S}/configure

}

gst-plugins_src_compile() {

	gst-plugins_src_configure ${@}

	gst-plugins_find_plugin_dir
	emake || die "compile failure"

}

gst-plugins_src_install() {

	gst-plugins_find_plugin_dir
	einstall || die

	dodoc README
}


gst-plugins_pkg_postinst() {

	gst-plugins_update_registry

}

gst-plugins_pkg_postrm() {

	gst-plugins_update_registry

}

EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
