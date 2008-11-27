# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gtk-sharp-module.eclass,v 1.5 2008/11/27 05:24:23 loki_val Exp $

# Author : Peter Johanson <latexer@gentoo.org>, butchered by ikelos, then loki_val.
# Based off of original work in gst-plugins.eclass by <foser@gentoo.org>

# Note that this breaks compatibility with the original gtk-sharp-component
# eclass.

inherit eutils mono multilib autotools

# Get the name of the component to build and the build dir; by default,
# extract it from the ebuild's name.
GTK_SHARP_MODULE=${GTK_SHARP_MODULE:=${PN/-sharp/}}
GTK_SHARP_MODULE_DIR=${GTK_SHARP_MODULE_DIR:=${PN/-sharp/}}

# In some cases the desired module cannot be configured to be built on its own.
# This variable allows for the setting of additional configure-deps.
GTK_SHARP_MODULE_DEPS="${GTK_SHARP_MODULE_DEPS}"

# Allow ebuilds to set a value for the required GtkSharp version; default to
# ${PV}.
GTK_SHARP_REQUIRED_VERSION=${GTK_SHARP_REQUIRED_VERSION:=${PV%.*}}

# Version number used to differentiate between unversioned 1.0 series and the
# versioned 2.0 series (2.0 series has 2 or 2.0 appended to various paths and
# scripts). Default to ${SLOT}.
GTK_SHARP_SLOT="${GTK_SHARP_SLOT:=${SLOT}}"
GTK_SHARP_SLOT_DEC="${GTK_SHARP_SLOT_DEC:=-${GTK_SHARP_SLOT}.0}"

# Set some defaults.
DESCRIPTION="GtkSharp's ${GTK_SHARP_MODULE} module"
HOMEPAGE="http://www.mono-project.com/GtkSharp"

LICENSE="LGPL-2.1"

RDEPEND="=dev-dotnet/gtk-sharp-${GTK_SHARP_REQUIRED_VERSION}*
	>=dev-lang/mono-2"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

RESTRICT="test"

# The GtkSharp modules are currently divided into three seperate tarball
# distributions. Figure out which of these our component belongs to. This is
# done to avoid passing bogus configure parameters, as well as to return the
# correct tarball to download. Note that this makes ${GTK_SHARP_TARBALL_PREFIX}
# obsolete.
gtk_sharp_module_list="glade"
gnome_sharp_module_list="art gnome gnomevfs"
gnome_desktop_sharp_module_list="gnome-print gnome-panel gtkhtml gtksourceview nautilusburn rsvg vte wnck"

if [[ " ${gtk_sharp_module_list} " == *" ${GTK_SHARP_MODULE} "* ]] ; then
	my_module_list="${gtk_sharp_module_list}"
	my_tarball="gtk-sharp"
elif [[ " ${gnome_sharp_module_list} " == *" ${GTK_SHARP_MODULE} "* ]] ; then
	my_module_list="${gnome_sharp_module_list}"
	my_tarball="gnome-sharp"

# While gnome-desktop-sharp is a part of gnome-desktop-sharp (0_o) it is not a
# configurable component, so we don't want to put it into the module list.
# Result is that we have to check for it manually here and in src_configure.
elif [[ " ${gnome_desktop_sharp_module_list} " == *" ${GTK_SHARP_MODULE} "* ||
		"${GTK_SHARP_MODULE}" == "gnome-desktop" ]] ; then
	my_module_list="${gnome_desktop_sharp_module_list}"
	my_tarball="gnome-desktop-sharp"
else
	die "unknown GtkSharp module: ${GTK_SHARP_MODULE}"
fi

MY_P=${my_tarball}-${PV}
S=${WORKDIR}/${MY_P}

# Since all interesting versions are hosted on the GNOME server anyway it's the
# only one we support, for now.
SRC_URI="mirror://gnome/sources/${my_tarball}/${PV%.*}/${MY_P}.tar.bz2
		mirror://gentoo/${MY_P}-configurable.diff.gz
		http://dev.gentoo.org/~ikelos/devoverlay-distfiles/${MY_P}-configurable.diff.gz"


### Public functions.

gtk-sharp-module_fix_files() {
	# Change references like "/r:../glib/glib-sharp.dll" ->
	# "/r:${GTK_SHARP_LIB_DIR}/glib-sharp.dll" and references like
	# "../glib/glib-sharp.xml" or "$(top_srcdir)/glib/glib-sharp.xml" ->
	# "${GAPI_DIR}/glib-sharp.xml".
	#
	# We also make sure to call the installed gapi-fixup and gapi-codegen and
	# not the ones that would be built locally.
	local gapi_dir="${ROOT}/usr/share/gapi${GTK_SHARP_SLOT_DEC}"
	local gapi_fixup="gapi${GTK_SHARP_SLOT}-fixup"
	local gapi_codegen="gapi${GTK_SHARP_SLOT}-codegen"

	# This is very likely to be of use outside of this function as well, so make
	# it public.
	GTK_SHARP_LIB_DIR="${ROOT}/usr/$(get_libdir)/mono/gtk-sharp${GTK_SHARP_SLOT_DEC}"

	local makefiles="$(find ${S} -name Makefile.in)"
	sed -i -e "s;\(\.\.\|\$(top_srcdir)\)/[[:alpha:]]*/\([[:alpha:]]*\(-[[:alpha:]]*\)*\).xml;${gapi_dir}/\2.xml;g" \
			-e "s;/r:\(\.\./\)*[[:alpha:]]*/\([[:alpha:]]*\(-[[:alpha:]]*\)*\).dll;/r:${GTK_SHARP_LIB_DIR}/\2.dll;g" \
			-e "s;\.\./[[:alpha:]]*/\([[:alpha:]]*\(-[[:alpha:]]*\)*\).dll;${GTK_SHARP_LIB_DIR}/\1.dll;g" \
			-e "s:\$(SYMBOLS) \$(top_builddir)/parser/gapi-fixup.exe:\$(SYMBOLS):" \
			-e "s:\$(INCLUDE_API) \$(top_builddir)/generator/gapi_codegen.exe:\$(INCLUDE_API):" \
			-e "s:\$(RUNTIME) \$(top_builddir)/parser/gapi-fixup.exe:${gapi_fixup}:" \
			-e "s:\$(RUNTIME) \$(top_builddir)/generator/gapi_codegen.exe:${gapi_codegen}:" \
			${makefiles} || die "failed to fix GtkSharp makefiles"

	# Oh GtkSharp, why do your pkgconfig entries suck donkey ass? Why do
	# gnome-desktop-sharp modules use ${assemblies_dir} for Libs: instead of
	# the convention you yourself introduced for gnome-sharp, which just uses
	# @PACKAGE_VERSION@? Are you just trying to annoy me?
	local pcins="$(find ${S} -name *.pc.in)"
	sed -i -e 's:^libdir.*:libdir=@libdir@:' \
			-e "s:\${assemblies_dir}:\${libdir}/mono/gtk-sharp${GTK_SHARP_SLOT_DEC}:" \
			${pcins} || die "failed to fix GtkSharp pkgconfig entries"
}

gtk-sharp-module_src_prepare() {
	# Make selecting components configurable.
	epatch ${WORKDIR}/${MY_P}-configurable.diff

	# Fixes support with pkgconfig-0.17, #92503.
	sed -i -e 's/\<PKG_PATH\>/GTK_SHARP_PKG_PATH/g' \
			-e ':^CFLAGS=:d' \
			"${S}"/configure.in

	# Fix install data hook, #161093.
	if [ -f "${S}/sample/gconf/Makefile.am" ]
	then
		sed -i -e 's/^install-hook/install-data-hook/' \
				"${S}"/sample/gconf/Makefile.am || die
	fi

	# Disable building samples, #16015.
	sed -i -e "s:sample::" "${S}"/Makefile.am || die

	eautoreconf

	cd "${S}"/${GTK_SHARP_MODULE_DIR}

	gtk-sharp-module_fix_files
}

gtk-sharp-module_src_configure() {
	# Disable any module besides one(s) we want.
	local module gtk_sharp_conf

	einfo "Configuring to build ${PN} module ..."

	# No bogus configure parameters please.
	[[ ${GTK_SHARP_MODULE} == "gnome-desktop" ]] && GTK_SHARP_MODULE=

	for module in ${GTK_SHARP_MODULE} ${GTK_SHARP_MODULE_DEPS} ; do
		my_module_list=${my_module_list/${module}/}
	done
	for module in ${my_module_list} ; do
		gtk_sharp_conf="${gtk_sharp_conf} --disable-${module} "
	done
	for module in ${GTK_SHARP_MODULE} ${GTK_SHARP_MODULE_DEPS} ; do
		gtk_sharp_conf="${gtk_sharp_conf} --enable-${module} "
	done

	cd "${S}"
	econf ${@} ${gtk_sharp_conf} || die "econf failed"
}

gtk-sharp-module_src_compile() {

	cd "${S}"/${GTK_SHARP_MODULE_DIR}
	LANG=C emake ${OVERRIDEJOBS} || die "emake failed"
}

gtk-sharp-module_src_install() {
	cd ${GTK_SHARP_MODULE_DIR}
	LANG=C emake ${OVERRIDEJOBS} GACUTIL_FLAGS="/root ${D}/usr/$(get_libdir) /gacdir /usr/$(get_libdir) /package gtk-sharp${GTK_SHARP_SLOT_DEC}" \
			DESTDIR="${D}" install || die "emake install failed"
}

EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install
