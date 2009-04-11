# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.34.1-r2.ebuild,v 1.9 2008/12/07 12:09:45 vapier Exp $

inherit distutils flag-o-matic multilib toolchain-funcs versionator check-reqs

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

MY_P=${PN}_$(replace_all_version_separators _)
PATCHSET_VERSION="${PV}-3"

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2
	mirror://gentoo/boost-patches-${PATCHSET_VERSION}.tbz2"
LICENSE="freedist Boost-1.0"
SLOT="0"
IUSE="debug doc icu pyste tools"

DEPEND="icu? ( >=dev-libs/icu-3.2 )
		sys-libs/zlib
		~dev-util/boost-build-${PV}"
RDEPEND="${DEPEND}
		pyste? ( dev-cpp/gccxml dev-python/elementtree )"

S=${WORKDIR}/${MY_P}

# Maintainer Information
# ToDo:
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

	EPATCH_SOURCE="${WORKDIR}/patches"
	EPATCH_SUFFIX="patch"
	epatch

	rm boost-build.jam

	# This enables building the boost.random library with /dev/urandom support
	if [[ ${CHOST} == *-linux-* ]] ; then
		mkdir -p libs/random/build
		cp "${FILESDIR}/random-Jamfile" libs/random/build/Jamfile.v2
	fi
}

generate_options() {
	LINK_OPTIONS="static shared"

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
	if [[ ${CHOST} == *-darwin* ]] ; then
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
		bjam ${NUMJOBS} -q \
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
		bjam ${NUMJOBS} -q \
			release debug-symbols=none \
			optimization=off \
			--prefix="${ED}/usr" \
			--layout=system \
			--user-config="${S}/user-config.jam" \
			|| die "building tools failed"
	fi

	if has test ${FEATURES} ; then
		cd "${S}/tools/regression/build"
		bjam -q \
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
		bjam -q \
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
		dohtml -A pdf,txt \
			*.htm *.png *.css \
			-r doc libs more people wiki

		# To avoid broken links
		insinto /usr/share/doc/${PF}/html
		doins LICENSE_1_0.txt

		dosym /usr/include/boost /usr/share/doc/${PF}/html/boost
	fi

	cd "${ED}/usr/$(get_libdir)"

	# If built with debug enabled, all libraries get a 'd' postfix,
	# this breaks linking other apps against boost (bug #181972)
	if use debug ; then
		for lib in $(ls -1 libboost_*) ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-d\././' -e 's/d\././' <<< ${lib})"
		done
	fi

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

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	# For AIX we might have to do the same trick, if we ever end up here on AIX
	case ${CHOST} in
		*-darwin*)
			for d in ${ED}usr/lib/*.dylib ; do
				if [[ -f ${d} ]] ; then
					# fix the "self reference"
					install_name_tool -id "/${d#${D}}" "${d}"
					# fix references to other libs
					refs=$(otool -L "${d}" | \
						sed -e '1d' -e 's/^\t//' | \
						grep bin.v2 | \
						cut -f1 -d' ')
					for r in ${refs} ; do
						install_name_tool -change \
							"${r}" \
							"${EPREFIX}/usr/lib/$(basename "${r}")" \
							"${d}"
					done
				fi
			done
		;;
	esac
}

src_test() {
	generate_options

	export BOOST_ROOT=${S}
	export BOOST_BUILD_PATH=/usr/share/boost-build

	cd "${S}/status"

	# Some of the test-checks seem to rely on regexps
	export LC_ALL="C"

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
