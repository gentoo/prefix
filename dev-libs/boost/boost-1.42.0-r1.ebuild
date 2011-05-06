# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boost/boost-1.42.0-r1.ebuild,v 1.3 2011/04/05 05:23:28 ulm Exp $

EAPI="2"

inherit python flag-o-matic multilib toolchain-funcs versionator check-reqs

MY_P=${PN}_$(replace_all_version_separators _)

DESCRIPTION="Boost Libraries for C++"
HOMEPAGE="http://www.boost.org/"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2"
LICENSE="Boost-1.0"
SLOT="$(get_version_component_range 1-2)"
IUSE="debug doc +eselect icu mpi python static-libs test tools"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris ~x86-winnt"

RDEPEND="icu? ( >=dev-libs/icu-3.3 )
	mpi? ( || ( sys-cluster/openmpi[cxx] sys-cluster/mpich2[cxx,threads] ) )
	sys-libs/zlib
	python? ( dev-lang/python )
	!!<=dev-libs/boost-1.35.0-r2
	!x86-winnt? ( >=app-admin/eselect-boost-0.3 )"
DEPEND="${RDEPEND}
	dev-util/boost-build:${SLOT}"

S=${WORKDIR}/${MY_P}

MAJOR_PV=$(replace_all_version_separators _ ${SLOT})
BJAM="bjam-${MAJOR_PV}"

# Usage:
# _add_line <line-to-add> <profile>
# ... to add to specific profile
# or
# _add_line <line-to-add>
# ... to add to all profiles for which the use flag set

_add_line() {
	if [ -z "$2" ] ; then
		echo "${1}" >> "${ED}/usr/share/boost-eselect/profiles/${SLOT}/default"
		use debug && echo "${1}" >> "${ED}/usr/share/boost-eselect/profiles/${SLOT}/debug"
	else
		echo "${1}" >> "${ED}/usr/share/boost-eselect/profiles/${SLOT}/${2}"
	fi
}

pkg_setup() {
	# It doesn't compile with USE="python mpi" and python-3 (bug 295705)
	if use python && use mpi ; then
		if [[ "$(python_get_version --major)" != "2" ]]; then
			eerror "The Boost.MPI python bindings do not support any other python version"
			eerror "than 2.x. Please either use eselect to select a python 2.x version or"
			eerror "disable the python and/or mpi use flag for =${CATEGORY}/${PF}."
			die "unsupported python version"
		fi
	fi

	if use test ; then
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

	if use debug ; then
		ewarn "The debug USE-flag means that a second set of the boost libraries"
		ewarn "will be built containing debug-symbols. You'll be able to select them"
		ewarn "using the boost-eselect module. But even though the optimization flags"
		ewarn "you might have set are not stripped, there will be a performance"
		ewarn "penalty and linking other packages against the debug version"
		ewarn "of boost is _not_ recommended."
	fi
}

src_prepare() {
	# WARNING: this one changes the threading API default to win32,
	# so keep this conditional. i found no other clean solution
	# right now, so ...
	if [[ ${CHOST} == *-winnt* ]]; then
		epatch "${FILESDIR}"/${PN}-1.35.0-winnt.patch
		epatch "${FILESDIR}"/${PN}-1.39.0-winnt.patch
	fi

	epatch "${FILESDIR}"/${PN}-1.37.0-darwin-long-double.patch

# Doesn't apply and no clue if it is needed. --darkside
	#epatch "${FILESDIR}"/${PN}-1.41.0-solaris-namespace-clash.patch

	epatch "${FILESDIR}/remove-toolset-${PV}.patch"

	 # bug 291660
	epatch "${FILESDIR}/boost-${PV}-parameter-needs-python.patch"
	epatch "${FILESDIR}"/${P}-template_arity-gcc45.patch

	# This enables building the boost.random library with /dev/urandom support
	if [[ -e /dev/urandom ]] ; then
		mkdir -p libs/random/build
		cp "${FILESDIR}/random-Jamfile" libs/random/build/Jamfile.v2
		# yeah, we WANT it to work on non-Linux too
		sed -i -e 's/#if defined(__linux__) || defined (__FreeBSD__)/#if 1/' \
			libs/random/random_device.cpp || die
	fi
}

src_configure() {
	einfo "Writing new user-config.jam"

	local compiler compilerVersion compilerExecutable mpi
	if [[ ${CHOST} == *-darwin* ]] ; then
		compiler=darwin
		compilerVersion=$(gcc-fullversion)
		compilerExecutable=$(tc-getCXX)
		# we need to add the prefix, and in two cases this exceeds, so prepare
		# for the largest possible space allocation
		append-ldflags -Wl,-headerpad_max_install_names
	elif [[ ${CHOST} == *-winnt* ]]; then
		compiler=parity
		if [[ $($(tc-getCXX) -v) == *trunk* ]]; then
			compilerVersion=trunk
		else
			compilerVersion=$($(tc-getCXX) -v | sed '1q' \
				| sed -e 's,\([a-z]*\) \([0-9]\.[0-9]\.[0-9][^ \t]*\) .*,\2,')
		fi
		compilerExecutable=$(tc-getCXX)
	else
		compiler=gcc
		compilerVersion=$(gcc-version)
		compilerExecutable=$(tc-getCXX)
	fi

	# Using -fno-strict-aliasing to prevent possible creation of invalid code.
	append-flags -fno-strict-aliasing

	# bug 298489
	if use ppc || use ppc64 ; then
		[[ $(gcc-version) > 4.3 ]] && append-flags -mno-altivec
	fi;

	use mpi && mpi="using mpi ;"

	if use python ; then
		pystring="using python : $(python_get_version) : ${EPREFIX}/usr : ${EPREFIX}$(python_get_includedir) : ${EPREFIX}$(python_get_libdir) ;"
	fi

	cat > "${S}/user-config.jam" << __EOF__

variant gentoorelease : release : <optimization>none <debug-symbols>none ;
variant gentoodebug : debug : <optimization>none ;

using ${compiler} : ${compilerVersion} : ${compilerExecutable} : <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;

${pystring}

${mpi}

__EOF__

	# Maintainer information:
	# The debug-symbols=none and optimization=none
	# are not official upstream flags but a Gentoo
	# specific patch to make sure that all our
	# CXXFLAGS/LDFLAGS are being respected.
	# Using optimization=off would for example add
	# "-O0" and override "-O2" set by the user.
	# Please take a look at the boost-build ebuild
	# for more infomration.

	use icu && OPTIONS="-sICU_PATH=${EPREFIX}/usr"
	use mpi || OPTIONS="${OPTIONS} --without-mpi"
	use python || OPTIONS="${OPTIONS} --without-python"

	# https://svn.boost.org/trac/boost/attachment/ticket/2597/add-disable-long-double.patch
	if use sparc || use mips || use hppa || use arm || use x86-fbsd || use sh; then
		OPTIONS="${OPTIONS} --disable-long-double"
	fi

	[[ ${CHOST} == *-winnt* ]] && OPTIONS="${OPTIONS} -sNO_BZIP2=1"

	local boost_build=$(type -P ${BJAM})
	boost_build=${boost_build%/*/*}/share/boost-build-${MAJOR_PV}
	OPTIONS="${OPTIONS} --user-config=\"${S}/user-config.jam\" --boost-build=${boost_build} --prefix=\"${ED}/usr\" --layout=versioned"

	if use static-libs ; then
		LINK_OPTS="link=shared,static"
		LIBRARY_TARGETS="*.a *$(get_libname)"
	else
		LINK_OPTS="link=shared"
		#there is no dynamicly linked version of libboost_test_exec_monitor
		LIBRARY_TARGETS="libboost_test_exec_monitor*.a *$(get_libname)"
	fi
}

src_compile() {
	jobs=$( echo " ${MAKEOPTS} " | \
		sed -e 's/ --jobs[= ]/ -j /g' \
			-e 's/ -j \([1-9][0-9]*\)/ -j\1/g' \
			-e 's/ -j\>/ -j1/g' | \
			( while read -d ' ' j ; do if [[ "${j#-j}" = "$j" ]]; then continue; fi; jobs="${j#-j}"; done; echo ${jobs} ) )
	if [[ "${jobs}" != "" ]]; then NUMJOBS="-j"${jobs}; fi;

	export BOOST_ROOT="${S}"

	local mythreading="single,multi"

	if [[ ${CHOST} == *-winnt* ]]; then
		mythreading="multi"
	fi

	einfo "Using the following command to build: "
	einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoorelease ${OPTIONS} threading=${mythreading} ${LINK_OPTS} runtime-link=shared"

	${BJAM} ${NUMJOBS} -q -d+2 \
		gentoorelease \
		${OPTIONS} \
		threading=${mythreading} ${LINK_OPTS} runtime-link=shared \
		|| die "building boost failed"

	# ... and do the whole thing one more time to get the debug libs
	if use debug ; then
		einfo "Using the following command to build: "
		einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoodebug ${OPTIONS} threading=${mythreading} ${LINK_OPTS} runtime-link=shared --buildid=debug"

		${BJAM} ${NUMJOBS} -q -d+2 \
			gentoodebug \
			${OPTIONS} \
			threading=${mythreading} ${LINK_OPTS} runtime-link=shared \
			--buildid=debug \
			|| die "building boost failed"
	fi

	if use tools; then
		cd "${S}/tools/"
		einfo "Using the following command to build the tools: "
		einfo "${BJAM} ${NUMJOBS} -q -d+2 gentoorelease ${OPTIONS}"

		${BJAM} ${NUMJOBS} -q -d+2\
			gentoorelease \
			${OPTIONS} \
			|| die "building tools failed"
	fi

}

src_install () {
	export BOOST_ROOT="${S}"

	local mythreading="single,multi"

	if [[ ${CHOST} == *-winnt* ]]; then
		mythreading="multi"
	fi

	einfo "Using the following command to install: "
	einfo "${BJAM} -q -d+2 gentoorelease ${OPTIONS} threading=${mythreading} ${LINK_OPTS} runtime-link=shared --includedir=\"${ED}/usr/include\" --libdir=\"${ED}/usr/$(get_libdir)\" install"

	${BJAM} -q -d+2 \
		gentoorelease \
		${OPTIONS} \
		threading=${mythreading} ${LINK_OPTS} runtime-link=shared \
		--includedir="${ED}/usr/include" \
		--libdir="${ED}/usr/$(get_libdir)" \
		install || die "install failed for options '${OPTIONS}'"

	if use debug ; then
		einfo "Using the following command to install: "
		einfo "${BJAM} -q -d+2 gentoodebug ${OPTIONS} threading=${mythreading} ${LINK_OPTS} runtime-link=shared --includedir=\"${ED}/usr/include\" --libdir=\"${ED}/usr/$(get_libdir)\" --buildid=debug"

		${BJAM} -q -d+2 \
			gentoodebug \
			${OPTIONS} \
			threading=${mythreading} ${LINK_OPTS} runtime-link=shared \
			--includedir="${ED}/usr/include" \
			--libdir="${ED}/usr/$(get_libdir)" \
			--buildid=debug \
			install || die "install failed for options '${OPTIONS}'"
	fi

	use python || rm -rf "${ED}/usr/include/boost-${MAJOR_PV}/boost"/python* || die

	dodir /usr/share/boost-eselect/profiles/${SLOT} || die
	touch "${ED}/usr/share/boost-eselect/profiles/${SLOT}/default" || die
	if use debug ; then
		 touch "${ED}/usr/share/boost-eselect/profiles/${SLOT}/debug" || die
	fi

	# Move the mpi.so to the right place and make sure it's slotted
	if use mpi && use python; then
		mkdir -p "${ED}$(python_get_sitedir)/boost_${MAJOR_PV}" || die
		mv "${ED}/usr/$(get_libdir)/mpi.so" "${ED}$(python_get_sitedir)/boost_${MAJOR_PV}/" || die
		touch "${ED}$(python_get_sitedir)/boost_${MAJOR_PV}/__init__.py" || die
		_add_line "python=\"${EPREFIX}$(python_get_sitedir)/boost_${MAJOR_PV}/mpi.so\""
	fi

	if use doc ; then
		find libs/*/* -iname "test" -or -iname "src" | xargs rm -rf
		dohtml \
			-A pdf,txt,cpp,hpp \
			*.{htm,html,png,css} \
			-r doc more people wiki || die
		dohtml \
			-A pdf,txt \
			-r tools || die
		insinto /usr/share/doc/${PF}/html
		doins -r libs || die

		# To avoid broken links
		insinto /usr/share/doc/${PF}/html
		doins LICENSE_1_0.txt || die

		dosym /usr/include/boost-${MAJOR_PV}/boost /usr/share/doc/${PF}/html/boost || die
	fi

	cd "${ED}/usr/$(get_libdir)" || die

	# Remove (unversioned) symlinks
	# And check for what we remove to catch bugs
	# got a better idea how to do it? tell me!
	for f in $(ls -1 ${LIBRARY_TARGETS} | grep -v "${MAJOR_PV}") ; do
		if [ ! -h "${f}" ] ; then
			eerror "Ups, tried to remove '${f}' which is a a real file instead of a symlink"
			die "slotting/naming of the libs broken!"
		fi
		rm "${f}" || die
	done

	# The threading libs obviously always gets the "-mt" (multithreading) tag
	# some packages seem to have a problem with it. Creating symlinks...

	if use static-libs ; then
		THREAD_LIBS="libboost_thread-mt-${MAJOR_PV}.a libboost_thread-mt-${MAJOR_PV}$(get_libname)"
	else
		THREAD_LIBS="libboost_thread-mt-${MAJOR_PV}$(get_libname)"
	fi
	for lib in ${THREAD_LIBS} ; do
		dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})" || die
	done

	# The same goes for the mpi libs
	if use mpi ; then
		if use static-libs ; then
			MPI_LIBS="libboost_mpi-mt-${MAJOR_PV}.a libboost_mpi-mt-${MAJOR_PV}$(get_libname)"
		else
			MPI_LIBS="libboost_mpi-mt-${MAJOR_PV}$(get_libname)"
		fi
		for lib in ${MPI_LIBS} ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})" || die
		done
	fi

	if use debug ; then
		if use static-libs ; then
			THREAD_DEBUG_LIBS="libboost_thread-mt-${MAJOR_PV}-debug$(get_libname) libboost_thread-mt-${MAJOR_PV}-debug.a"
		else
			THREAD_DEBUG_LIBS="libboost_thread-mt-${MAJOR_PV}-debug$(get_libname)"
		fi

		for lib in ${THREAD_DEBUG_LIBS} ; do
			dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})" || die
		done

		if use mpi ; then
			if use static-libs ; then
				MPI_DEBUG_LIBS="libboost_mpi-mt-${MAJOR_PV}-debug.a libboost_mpi-mt-${MAJOR_PV}-debug$(get_libname)"
			else
				MPI_DEBUG_LIBS="libboost_mpi-mt-${MAJOR_PV}-debug$(get_libname)"
			fi

			for lib in ${MPI_DEBUG_LIBS} ; do
				dosym ${lib} "/usr/$(get_libdir)/$(sed -e 's/-mt//' <<< ${lib})" || die
			done
		fi
	fi

	# Create a subdirectory with completely unversioned symlinks
	# and store the names in the profiles-file for eselect
	dodir /usr/$(get_libdir)/boost-${MAJOR_PV} || die

	_add_line "libs=\"" default
	for f in $(ls -1 ${LIBRARY_TARGETS} | grep -v debug) ; do
		dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}/${f/-${MAJOR_PV}} || die
		_add_line "${EPREFIX}/usr/$(get_libdir)/${f}" default
	done
	_add_line "\"" default

	if use debug ; then
		_add_line "libs=\"" debug
		dodir /usr/$(get_libdir)/boost-${MAJOR_PV}-debug || die
		for f in $(ls -1 ${LIBRARY_TARGETS} | grep debug) ; do
			dosym ../${f} /usr/$(get_libdir)/boost-${MAJOR_PV}-debug/${f/-${MAJOR_PV}-debug} || die
			_add_line "${EPREFIX}/usr/$(get_libdir)/${f}" debug
		done
		_add_line "\"" debug

		_add_line "includes=\"${EPREFIX}/usr/include/boost-${MAJOR_PV}/boost\"" debug
		_add_line "suffix=\"-debug\"" debug
	fi

	_add_line "includes=\"${EPREFIX}/usr/include/boost-${MAJOR_PV}/boost\"" default

	if use tools; then
		cd "${S}/dist/bin" || die
		# Append version postfix to binaries for slotting
		_add_line "bins=\""
		for b in * ; do
			newbin "${b}" "${b}-${MAJOR_PV}" || die
			_add_line "${EPREFIX}/usr/bin/${b}-${MAJOR_PV}"
		done
		_add_line "\""

		cd "${S}/dist" || die
		insinto /usr/share || die
		doins -r share/boostbook || die
		# Append version postfix for slotting
		mv "${ED}/usr/share/boostbook" "${ED}/usr/share/boostbook-${MAJOR_PV}" || die
		_add_line "dirs=\"${EPREFIX}/usr/share/boostbook-${MAJOR_PV}\""
	fi

	cd "${S}/status" || die
	if [ -f regress.log ] ; then
		docinto status || die
		dohtml *.html ../boost.png || die
		dodoc regress.log || die
	fi

	use python && python_need_rebuild

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	[[ -z ${ED+set} ]] && local ED=${D%/}${EPREFIX}/
	if [[ ${CHOST} == *-darwin* ]] ; then
		einfo "Working around completely broken build-system(tm)"
		for d in "${ED}"usr/lib/*.dylib ; do
			if [[ -f ${d} ]] ; then
				# fix the "soname"
				ebegin "  correcting install_name of ${d#${ED}}"
				install_name_tool -id "/${d#${D}}" "${d}"
				eend $?
				# fix references to other libs
				refs=$(otool -XL "${d}" | \
					sed -e '1d' -e 's/^\t//' | \
					grep "^libboost_" | \
					cut -f1 -d' ')
				for r in ${refs} ; do
					ebegin "    correcting reference to ${r}"
					install_name_tool -change \
						"${r}" \
						"${EPREFIX}/usr/lib/${r}" \
						"${d}"
					eend $?
				done
			fi
		done
	fi

	# on winnt we don't have eselect-boost support (yet), so create
	# symlinks/copies where required.
	if [[ ${CHOST} == *-winnt* ]]; then
		(
			if use debug; then
				. "${ED}/usr/share/boost-eselect/profiles/${SLOT}/debug"
			else
				. "${ED}/usr/share/boost-eselect/profiles/${SLOT}/default"
			fi

			test -z "${includes}" -o -z "${libs}" && die "oops. something went wrong - boost profile damaged!"

			dodir /usr/include
			cp -r "${D}"${includes} "${ED}/usr/include/"

			dodir /usr/$(get_libdir)
			for f in ${libs}; do
				linkname="${f#${EPREFIX}}"
				dosym ${linkname} "${linkname/-${MAJOR_PV}}"
			done
		) || die
	fi
}

src_test() {
	export BOOST_ROOT=${S}

	cd "${S}/tools/regression/build" || die
	einfo "Using the following command to build test helpers: "
	einfo "${BJAM} -q -d+2 gentoorelease ${OPTIONS} process_jam_log compiler_status"

	${BJAM} -q -d+2 \
		gentoorelease \
		${OPTIONS} \
		process_jam_log compiler_status \
		|| die "building regression test helpers failed"

	cd "${S}/status" || die

	# Some of the test-checks seem to rely on regexps
	export LC_ALL="C"

	# The following is largely taken from tools/regression/run_tests.sh,
	# but adapted to our needs.

	# Run the tests & write them into a file for postprocessing
	einfo "Using the following command to test: "
	einfo "${BJAM} ${OPTIONS} --dump-tests"

	${BJAM} \
		${OPTIONS} \
		--dump-tests 2>&1 | tee regress.log || die

	# Postprocessing
	cat regress.log | "${S}/tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease/pch-off/process_jam_log" --v2
	if test $? != 0 ; then
		die "Postprocessing the build log failed"
	fi

	cat > "${S}/status/comment.html" <<- __EOF__
		<p>Tests are run on a <a href="http://www.gentoo.org">Gentoo</a> system.</p>
__EOF__

	# Generate the build log html summary page
	"${S}/tools/regression/build/bin/gcc-$(gcc-version)/gentoorelease/pch-off/compiler_status" --v2 \
		--comment "${S}/status/comment.html" "${S}" \
		cs-$(uname).html cs-$(uname)-links.html
	if test $? != 0 ; then
		die "Generating the build log html summary page failed"
	fi

	# And do some cosmetic fixes :)
	sed -i -e 's|http://www.boost.org/boost.png|boost.png|' *.html || die
}

pkg_postinst() {
	# no eselect-boost on winnt. we simply override the slotting back 
	# to the # "old" behaviour -> install files where they belong ;)
	# (done above in src_install, so portage knows the files.)
	if [[ ${CHOST} != *-winnt* ]]; then
	use eselect && eselect boost update
	if [ ! -h "${EROOT}/etc/eselect/boost/active" ] ; then
		elog "No active boost version found. Calling eselect to select one..."
		eselect boost update || ewarn "eselect boost update failed."
	fi
	fi
}
