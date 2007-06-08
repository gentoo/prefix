# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.34.0.ebuild,v 1.1 2007/06/06 19:25:19 dev-zero Exp $

EAPI="prefix"

inherit distutils flag-o-matic multilib toolchain-funcs versionator check-reqs

KEYWORDS="~amd64 ~x86 ~x86-macos ~x86-solaris"

MY_P=${PN}_$(replace_all_version_separators _)

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2"
LICENSE="freedist Boost-1.0"
SLOT="0"
IUSE="debug doc icu pyste tools userland_Darwin"

DEPEND="icu? ( >=dev-libs/icu-3.2 )
		sys-libs/zlib
		~dev-util/boost-build-${PV}"
RDEPEND="${DEPEND}
		pyste? ( dev-cpp/gccxml dev-python/elementtree )"

S=${WORKDIR}/${MY_P}

# Maintainer Information
# ToDo:
# - gccxml needed by pyste is broken with >=gcc-4.1.1 (bug #147976)
# - write a patch to support /dev/urandom on FreeBSD and OSX (see below)

pkg_setup() {
	if has test ${FEATURES} ; then
		CHECKREQS_DISK_BUILD="1024"
		check_reqs

		ewarn "The tests may take several hours on a recent machine"
		ewarn "but they will not fail (unless something weird happens ;-)"
		ewarn "This is because the tests depend on the used compiler/-version"
		ewarn "and the platform and upstream says that this is normal."
		ewarn "If you are interested in the results, please take a look at the"
		ewarn "generated results page:"
		ewarn "  ${EROOT}usr/share/doc/${PF}/status/cs-$(uname).html"
		ebeep 5

	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	rm boost-build.jam

	# This enables building the boost.random library with /dev/urandom support
	if ! use userland_Darwin ; then
		mkdir -p libs/random/build
		cp "${FILESDIR}/random-Jamfile" libs/random/build/Jamfile.v2
	fi
}

generate_options() {
	LINK_OPTIONS="shared static"

	# Maintainer information:
	# The debug-symbols=none and optimization=none
	# are not official upstream flags but a Gentoo
	# specific patch to make sure that all our
	# CXXFLAGS/LDFLAGS are being respected.
	# Using optimization=off would for example add
	# "-O0" and override "-O2" set by the user.
	# Please take a look at the boost-build ebuild
	# for more infomration.
	if ! use debug ; then
		OPTIONS="release debug-symbols=none"
	else
		OPTIONS="debug"
	fi

	OPTIONS="${OPTIONS} optimization=none"

	use icu && OPTIONS="${OPTIONS} -sHAVE_ICU=1 -sICU_PATH='${EPREFIX}'/usr"

	OPTIONS="${OPTIONS} --user-config=${S}/user-config.jam"
}

generate_userconfig() {
	einfo "Writing new user-config.jam"
	distutils_python_version

	local compiler compilerVersion compilerExecutable
	if use userland_Darwin ; then
		compiler=darwin
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
		append-ldflags -ldl
	else
		compiler=gcc
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
	fi

	cat > "${S}/user-config.jam" << __EOF__
import toolset : using ;
import toolset : flags ;
using ${compiler} : ${compilerVersion} : ${compilerExecutable} : <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;
using python : ${PYVER} : ${EPREFIX}/usr : ${EPREFIX}/usr/include/python${PYVER} : ${EPREFIX}/usr/lib/python${PYVER} ;
__EOF__

}

src_compile() {

	NUMJOBS=$(sed -e 's/.*\(\-j[ 0-9]\+\) .*/\1/' <<< ${MAKEOPTS})

	generate_userconfig
	generate_options

	elog "Using the following options to build: "
	elog "  ${OPTIONS}"

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=${EPREFIX}/usr/share/boost-build

	for linkoption in ${LINK_OPTIONS} ; do
		einfo "Building ${linkoption} libraries"
		bjam ${NUMJOBS} \
			${OPTIONS} \
			threading=single,multi \
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
			release debug-symbols=none \
			optimization=off \
			--prefix="${ED}/usr" \
			--layout=system \
			--user-config="${S}/user-config.jam" \
			|| die "building tools failed"
	fi

	if has test ${FEATURES} ; then
		cd "${S}/tools/regression/build"
		bjam \
			${OPTIONS} \
			--prefix="${ED}/usr" \
			--layout=system \
			|| die "building regression test helpers failed"
	fi

}

src_install () {

	generate_options

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=${EPREFIX}/usr/share/boost-build

	for linkoption in ${LINK_OPTIONS} ; do
		bjam \
			${OPTIONS} \
			threading=single,multi \
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

	if has test ${FEATURES} ; then
		cd "${S}/status"
		docinto status
		dohtml *.{html,gif} ../boost.png
		dodoc regress.log
	fi
}

src_test() {
	generate_options

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=/usr/share/boost-build

	cd "${S}/status"

	# The following is largely taken from tools/regression/run_tests.sh,
	# but adapted to our needs.

	# Run the tests & write them into a file for postprocessing
	bjam \
		${OPTIONS} \
		--dump-tests 2>&1 | tee regress.log

	# Postprocessing
	cat regress.log | "${S}/dist/bin/process_jam_log" --v2
	if test $? != 0 ; then
		die "Postprocessing the build log failed"
	fi

	cat > "${S}/status/comment.html" <<- __EOF__
		<p>Tests are run on a <a href="http://www.gentoo.org">Gentoo</a> system.</p>
__EOF__

	# Generate the build log html summary page
	"${S}/dist/bin/compiler_status" --v2 \
		--comment "${S}/status/comment.html" "${S}" \
		cs-$(uname).html cs-$(uname)-links.html
	if test $? != 0 ; then
		die "Generating the build log html summary page failed"
	fi

	# And do some cosmetic fixes :)
	sed -i -e 's|../boost.png|boost.png|' *.html
}
