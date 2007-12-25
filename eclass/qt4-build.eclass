# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt4-build.eclass,v 1.6 2007/12/23 20:48:30 caleb Exp $

# @ECLASS: qt4-build.eclass
# @MAINTAINER:
# Caleb Tennis <caleb@gentoo.org>
# @BLURB:
# Eclass for Qt4 
# @DESCRIPTION:
# This eclass contains various functions that are used when building Qt4

inherit eutils multilib toolchain-funcs flag-o-matic

IUSE="${IUSE} debug"

qt4-build_pkg_setup() {
	# Set up installation directories

	QTBASEDIR=/usr/$(get_libdir)/qt4
	QTPREFIXDIR=/usr
	QTBINDIR=/usr/bin
	QTLIBDIR=/usr/$(get_libdir)/qt4
	QTPCDIR=/usr/$(get_libdir)/pkgconfig
	QTDATADIR=/usr/share/qt4
	QTDOCDIR=/usr/share/doc/qt-${PV}
	QTHEADERDIR=/usr/include/qt4
	QTPLUGINDIR=${QTLIBDIR}/plugins
	QTSYSCONFDIR=/etc/qt4
	QTTRANSDIR=${QTDATADIR}/translations
	QTEXAMPLESDIR=${QTDATADIR}/examples
	QTDEMOSDIR=${QTDATADIR}/demos

	PLATFORM=$(qt_mkspecs_dir)

	PATH="${S}/bin:${PATH}"
	LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"
}

qt4-build_src_unpack() {
	unpack ${A}
	cd "${S}"

	# Don't let the user go too overboard with flags.  If you really want to, uncomment
	# out the line below and give 'er a whirl.
	strip-flags
	replace-flags -O3 -O2

	if [[ $( gcc-fullversion ) == "3.4.6" && gcc-specs-ssp ]] ; then
		ewarn "Appending -fno-stack-protector to CFLAGS/CXXFLAGS"
		append-flags -fno-stack-protector
	fi
}

qt4-build_src_install() {
	install_directories "${QT4_TARGET_DIRECTORIES}"
	fix_library_files
}

standard_configure_options() {
	local myconf=""

	[ $(get_libdir) != "lib" ] && myconf="${myconf} -L/usr/$(get_libdir)"

	# Disable visibility explicitly if gcc version isn't 4
	if [[ "$(gcc-major-version)" != "4" ]]; then
		myconf="${myconf} -no-reduce-exports"
	fi

	use debug && myconf="${myconf} -debug -no-separate-debug-info" || myconf="${myconf} -release -no-separate-debug-info"

	myconf="${myconf} -stl -verbose -largefile -confirm-license -no-rpath\
	-prefix ${QTPREFIXDIR} -bindir ${QTBINDIR} -libdir ${QTLIBDIR} -datadir ${QTDATADIR} \
	-docdir ${QTDOCDIR} -headerdir ${QTHEADERDIR} -plugindir ${QTPLUGINDIR} \
	-sysconfdir ${QTSYSCONFDIR} -translationdir ${QTTRANSDIR} \
	-examplesdir ${QTEXAMPLESDIR} -demosdir ${QTDEMOSDIR}"

	myconf="${myconf} -silent -fast -reduce-relocations -nomake examples -nomake demos"

	echo "${myconf}"
}

build_target_directories() {
	build_directories "${QT4_TARGET_DIRECTORIES}"
}

build_directories() {
	local dirs="$@"
	for x in ${dirs}; do
		cd "${S}"/${x}
		"${S}"/bin/qmake "LIBS+=-L${QTLIBDIR}" "CONFIG+=nostrip" && emake || die
	done
}

install_directories() {
	local dirs="$@"
	for x in ${dirs}; do
		cd "${S}"/${x}
		emake INSTALL_ROOT="${D}" install || die
	done
}

qconfig_add_option() {
	local option=$1
	qconfig_remove_option $1
	sed -i -e "s:QT_CONFIG +=:QT_CONFIG += ${option}:g" /usr/share/qt4/mkspecs/qconfig.pri
}

qconfig_remove_option() {
	local option=$1
	sed -i -e "s: ${option}::g" /usr/share/qt4/mkspecs/qconfig.pri
}

skip_qmake_build_patch() {
	# Don't need to build qmake, as it's already installed from qmake-core
	sed -i -e "s:if true:if false:g" "${S}"/configure
}

skip_project_generation_patch() {
	# Exit the script early by throwing in an exit before all of the .pro files are scanned
	sed -i -e "s:echo \"Finding:exit 0\n\necho \"Finding:g" "${S}"/configure
}

install_binaries_to_buildtree()
{
	cp ${QTBINDIR}/qmake ${S}/bin
	cp ${QTBINDIR}/moc ${S}/bin
	cp ${QTBINDIR}/uic ${S}/bin
	cp ${QTBINDIR}/rcc ${S}/bin
}

fix_library_files() {
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/*.la
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/*.prl
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g" "${D}"/${QTLIBDIR}/pkgconfig/*.pc

	# pkgconfig files refer to WORKDIR/bin as the moc and uic locations.  Fix:
	sed -i -e "s:${S}/bin:${QTBINDIR}:g" "${D}"/${QTLIBDIR}/pkgconfig/*.pc

	# Move .pc files into the pkgconfig directory
	dodir ${QTPCDIR}
	mv "${D}"/${QTLIBDIR}/pkgconfig/*.pc "${D}"/${QTPCDIR}
}

qt_use() {
	local flag="$1"
	local feature="$1"
	local enableval=

	[[ -n $2 ]] && feature=$2
	[[ -n $3 ]] && enableval="-$3"

	useq $flag && echo "${enableval}-${feature}" || echo "-no-${feature}"
	return 0
}

qt_mkspecs_dir() {
	# Allows us to define which mkspecs dir we want to use.
	local spec

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec="freebsd" ;;
		*-openbsd*)
			spec="openbsd" ;;
		*-netbsd*)
			spec="netbsd" ;;
 		*-darwin*)
			spec="darwin" ;;
		*-linux-*|*-linux)
			spec="linux" ;;
		*)
			die "Unknown CHOST, no platform choosed."
	esac

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler ${CXX}."
	fi

	echo "${spec}"
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_install
