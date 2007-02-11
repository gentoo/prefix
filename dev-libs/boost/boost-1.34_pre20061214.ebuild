# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.34_pre20061214.ebuild,v 1.3 2007/02/10 12:38:14 dev-zero Exp $

EAPI="prefix"

inherit distutils flag-o-matic multilib toolchain-funcs versionator

KEYWORDS="~amd64 ~x86 ~x86-macos"

MY_P=${PN}_$(replace_all_version_separators _)

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="http://dev.gentoo.org/~dev-zero/distfiles/${MY_P}.tar.bz2"
LICENSE="freedist Boost-1.0"
SLOT="0"
IUSE="debug doc icc icu pyste tools userland_Darwin"

DEPEND="icu? ( >=dev-libs/icu-3.2 )
		sys-libs/zlib
		~dev-util/boost-build-${PV}"
RDEPEND="${DEPEND}
		pyste? ( dev-cpp/gccxml dev-python/elementtree )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	rm boost-build.jam

	if ! use userland_Darwin ; then
		mkdir -p libs/random/build
		cp "${FILESDIR}/random-Jamfile" libs/random/build/Jamfile.v2
	fi
}

generate_options() {
	LINK_OPTIONS="shared static"

	if ! use debug ; then
		OPTIONS="release debug-symbols=none"
	else
		OPTIONS="debug"
	fi

	OPTIONS="${OPTIONS} optimization=none"
	OPTIONS="${OPTIONS} threading=single,multi"

	use icu && OPTIONS="${OPTIONS} -sHAVE_ICU=1 -sICU_PATH=\"${EROOT}/usr\""

}

generate_userconfig() {
	einfo "Writing new user-config.jam"
	distutils_python_version

	local compiler compilerVersion compilerExecutable
	if use icc ; then
		compiler=intel-linux
		compilerExecutable=icc
	elif use userland_Darwin ; then
		compiler=darwin
		compilerExecutable=c++
		append-ldflags -ldl
	else
		compiler=gcc
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
	fi

	cat > "${HOME}/user-config.jam" << __EOF__
import toolset : using ;
import toolset : flags ;
using ${compiler} : ${compilerVersion} : ${compilerExecutable} : <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;
using python : ${PYVER} : ${EROOT}usr : ${EROOT}usr/include/python${PYVER} : ${EROOT}usr/lib/python${PYVER} ;
__EOF__

}

src_compile() {

	NUMJOBS=$(sed -e 's/.*\(\-j[ 0-9]\+\) .*/\1/' <<< ${MAKEOPTS})

	generate_userconfig
	generate_options

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=${EROOT}/usr/share/boost-build

	# Note: The line "debug-symbols=on" only adds '-g' to compiler and linker invocation
	# and prevents boost-build from stripping the libraries/binaries
	for linkoption in ${LINK_OPTIONS} ; do
		einfo "Building ${linkoption} libraries"
		bjam ${NUMJOBS} \
			${OPTIONS} \
			runtime-link=${linkoption} link=${linkoption} \
			--prefix="${ED}/usr" \
			--layout=system \
			|| die "building boost failed"
	done

	if use pyste; then
		cd "${S}/libs/python/pyste/install"
		distutils_src_compile
	fi

	if use tools; then
		cd "${S}/tools/"
		# We have to set optimization to -O0 or -O1 to work around a gcc-bug
		# optimization=off adds -O0 to the compiler call and overwrites our settings.
		bjam ${NUMJOBS} \
			release \
			debug-symbols=none \
			optimization=off \
			--prefix="${ED}/usr" \
			--layout=system || die "building tools failed"
	fi
}

src_install () {

	generate_options

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=${EROOT}/usr/share/boost-build

	for linkoption in ${LINK_OPTIONS} ; do
		bjam \
			${OPTIONS} \
			runtime-link=${linkoption} link=${linkoption} \
			--prefix="${ED}/usr" \
			--includedir="${ED}/usr/include" \
			--libdir="${ED}/usr/$(get_libdir)" \
			--layout=system \
			install || die "install failed"
	done

	dodoc README

	if use doc ; then
		dohtml -A .pdf,.txt \
			*.htm *.gif *.css \
			-r doc libs more people wiki
	fi

	cd "${ED}/usr/$(get_libdir)"

	for lib in $(ls -1 libboost_thread-mt.*) ; do
		dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})"
	done

	if use pyste; then
		cd "${S}/libs/python/pyste/install"
		distutils_src_install
	fi

	if use tools; then
		cd "${S}/dist"
		dobin bin/*
		insinto /usr
		doins -r share
	fi

}
