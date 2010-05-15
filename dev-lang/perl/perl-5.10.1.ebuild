# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/perl/perl-5.10.1.ebuild,v 1.21 2010/03/31 18:49:57 armin76 Exp $

EAPI=2

inherit eutils alternatives flag-o-matic toolchain-funcs multilib

PATCH_VER=9

PERL_OLDVERSEN="5.10.0"

SHORT_PV="${PV%.*}"
MY_P="perl-${PV/_rc/-RC}"
MY_PV="${PV%_rc*}"

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"

S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://cpan/src/${MY_P}.tar.bz2
	mirror://gentoo/${MY_P}-${PATCH_VER}.tar.bz2
	http://dev.gentoo.org/~tove/files/${MY_P}-${PATCH_VER}.tar.bz2"
HOMEPAGE="http://www.perl.org/"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="berkdb build debug doc gdbm ithreads"

COMMON_DEPEND="berkdb? ( sys-libs/db )
	gdbm? ( >=sys-libs/gdbm-1.8.3 )
	>=sys-devel/libperl-5.10.1
	!!<sys-devel/libperl-5.10.1
	app-arch/bzip2
	sys-libs/zlib"
DEPEND="${COMMON_DEPEND}
	!prefix? ( elibc_FreeBSD? ( sys-freebsd/freebsd-mk-defs ) )"
RDEPEND="${COMMON_DEPEND}"
PDEPEND=">=app-admin/perl-cleaner-2_pre090920"

dual_scripts() {
	src_remove_dual_scripts perl-core/Archive-Tar        1.52    ptar ptardiff
	src_remove_dual_scripts perl-core/Digest-SHA         5.47    shasum
	src_remove_dual_scripts perl-core/CPAN               1.9402  cpan
	src_remove_dual_scripts perl-core/CPANPLUS           0.88    cpanp cpan2dist cpanp-run-perl
	src_remove_dual_scripts perl-core/Encode             2.35    enc2xs piconv
	src_remove_dual_scripts perl-core/ExtUtils-MakeMaker 6.55_02 instmodsh
	src_remove_dual_scripts perl-core/Module-Build       0.34_02 config_data
	src_remove_dual_scripts perl-core/Module-CoreList    2.18    corelist
	src_remove_dual_scripts perl-core/PodParser          1.37    pod2usage podchecker podselect
	src_remove_dual_scripts perl-core/Test-Harness       3.17    prove
	src_remove_dual_scripts perl-core/podlators          2.2.2   pod2man pod2text
}

pkg_setup() {
	LIBPERL="libperl$(get_libname ${MY_PV})"

	if use ithreads ; then
		ewarn "THREADS WARNING:"
		ewarn "PLEASE NOTE: You are compiling ${MY_P} with"
		ewarn "interpreter-level threading enabled."
		ewarn "Threading is not supported by all applications "
		ewarn "that compile against perl. You use threading at "
		ewarn "your own discretion. "
		echo
	fi
	if has_version "~dev-lang/perl-5.8.8" ; then
		ewarn "UPDATE THE PERL MODULES:"
		ewarn "After updating dev-lang/perl you must reinstall"
		ewarn "the installed perl modules."
		ewarn "Use: perl-cleaner --all"
	elif has_version dev-lang/perl ; then
		# doesnot work
		#if ! has_version dev-lang/perl[ithreads=,debug=] ; then
		#if ! has_version dev-lang/perl[ithreads=] || ! has_version dev-lang/perl[debug=] ; then
		if (   use ithreads && ! has_version dev-lang/perl[ithreads]   ) || \
		   ( ! use ithreads &&   has_version dev-lang/perl[ithreads]   ) || \
		   (   use debug    && ! has_version dev-lang/perl[debug]      ) || \
		   ( ! use debug    &&   has_version dev-lang/perl[debug]      ) ; then
			ewarn "TOGGLED USE-FLAGS WARNING:"
			ewarn "You changed one of the use-flags ithreads or debug."
			ewarn "You must rebuild all perl-modules installed."
			ewarn "Use: perl-cleaner --modules ; perl-cleaner --force --libperl"
		fi
	fi
	dual_scripts
}

src_prepare() {
	EPATCH_SOURCE="${WORKDIR}/perl-patch" \
	EPATCH_SUFFIX="diff" \
	EPATCH_FORCE="yes" \
	epatch

	# pod/perltoc.pod fails
	ln -s ${LIBPERL} libperl$(get_libname ${SHORT_PV})
	ln -s ${LIBPERL} libperl$(get_libname )

	# commented out patches fail and need evaluation if they're still necessary
	#epatch "${FILESDIR}"/${PN}-5.8.8-mint.patch
	#epatch "${FILESDIR}"/${PN}-5.8.8-aix.patch
	#epatch "${FILESDIR}"/${PN}-5.8.8-solaris-64bit.patch # may clash with native linker
	epatch "${FILESDIR}"/${PN}-5.8.8-solaris-relocation.patch
	epatch "${FILESDIR}"/${PN}-5.8.8-irix.patch
	epatch "${FILESDIR}"/${P}-cleanup-paths.patch
	epatch "${FILESDIR}"/${PN}-5.8.8-usr-local.patch
	epatch "${FILESDIR}"/${P}-hpux.patch
	#epatch "${FILESDIR}"/${PN}-5.8.8-hpux1131.patch
	epatch "${FILESDIR}"/${PN}-5.8.8-darwin-cc-ld.patch
	epatch "${FILESDIR}"/${P}-stack-protector-check.patch

	# rest of usr-local patch
	sed -i \
		-e '/^locincpth=/c\locincpth=""' \
		-e '/^loclibpth=/c\loclibpth=""' \
		-e '/^glibpth=.*\/local\//s: /usr/local/lib.*":":' \
		Configure || die

	# Also add the directory prefix of the current file when the quote syntax is
	# used; 'require' will only look in @INC, not the current directory.
	#epatch "${FILESDIR}"/${PN}-fix_h2ph_include_quote.patch

	# on interix, $firstmakefile may not be 'makefile', since the
	# filesystem may be case insensitive, and perl will wrongly
	# delete Makefile.
	#epatch "${FILESDIR}"/${P}-interix-firstmakefile.patch
	#epatch "${FILESDIR}"/${P}-interix-misc.patch
}

myconf() {
	# the myconf array is declared in src_configure
	myconf=( "${myconf[@]}" "$@" )
}

src_configure() {
	declare -a myconf

	# some arches and -O do not mix :)
	use ppc && replace-flags -O? -O1
	# Perl has problems compiling with -Os in your flags with glibc
	use elibc_uclibc || replace-flags "-Os" "-O2"
	# This flag makes compiling crash in interesting ways
	filter-flags "-malign-double"
	# Fixes bug #97645
	use ppc && filter-flags "-mpowerpc-gpopt"
	# Fixes bug #143895 on gcc-4.1.1
	filter-flags "-fsched2-use-superblocks"

	# this is needed because gcc 3.3-compiled kernels will hang
	# the machine trying to run this test - check with `Kumba
	# <rac@gentoo.org> 2003.06.26
	use mips && myconf -Dd_u32align

	use sparc && myconf -Ud_longdbl

	export LC_ALL="C"

	# 266337
	export BUILD_BZIP2=0
	export BZIP2_INCLUDE=${EPREFIX}/usr/include
	export BZIP2_LIB=${EPREFIX}/usr/$(get_libdir)
	cat <<-EOF > "${S}/ext/Compress-Raw-Zlib/config.in"
		BUILD_ZLIB = False
		INCLUDE = ${EPREFIX}/usr/include
		LIB = ${EPREFIX}/usr/$(get_libdir)

		OLD_ZLIB = False
		GZIP_OS_CODE = AUTO_DETECT
	EOF

	case ${CHOST} in
		*-freebsd*)   osname="freebsd" ;;
		*-dragonfly*) osname="dragonfly" ;;
		*-netbsd*)    osname="netbsd" ;;
		*-openbsd*)   osname="openbsd" ;;
		*-darwin*)    osname="darwin" ;;
		*-solaris*)
			osname="solaris"
			# solaris2.9 has /lib/libgdbm.so.2 and /lib/libgdbm.so.3,
			# but no linkable /lib/libgdbm.so.
			# This might apply to others too, but seen on solaris only yet.
			myconf -Dignore_versioned_solibs
			;;
		*-aix*)       osname="aix" ;;
		*-hpux*)      osname="hpux" ;;
		*-irix*)
			osname="irix"
			myconf -Dcc="cc -n32 -mips4"
			use ithreads && myconf -Dlibs="-lm -lpthread" || myconf -Dlibs="-lm"
			;;
		*-interix*)   osname='interix' ;;
		*-mint*)      osname="freemint" ;;
		*)            osname="linux" ;;
	esac

	case ${CHOST} in
		*-irix*)
		myconf -Dccdlflags='-exports'
		;;
	*)
		myconf -Dccdlflags='-rdynamic'
		;;
	esac

	if use ithreads ; then
		mythreading="-multi"
		myconf -Dusethreads
		myarch=${CHOST}
		myarch="${myarch%%-*}-${osname}-thread"
	else
		myarch=${CHOST}
		myarch="${myarch%%-*}-${osname}"
	fi
	if use debug ; then
		myarch="${myarch}-debug"
	fi

	# allow either gdbm to provide ndbm (in <gdbm/ndbm.h>) or db1

	myndbm='U'
	mygdbm='U'
	mydb='U'

	if use gdbm ; then
		mygdbm='D'
		myndbm='D'
	fi
	if use berkdb ; then
		mydb='D'
		has_version '=sys-libs/db-1*' && myndbm='D'
	fi

	myconf "-${myndbm}i_ndbm" "-${mygdbm}i_gdbm" "-${mydb}i_db"

	if use alpha && [[ "$(tc-getCC)" = "ccc" ]] ; then
		ewarn "Perl will not be built with berkdb support, use gcc if you needed it..."
		myconf -Ui_db -Ui_ndbm
	fi

	if use debug ; then
		append-cflags "-g"
		myconf -DDEBUGGING
	fi

	local inclist=$(for v in ${PERL_OLDVERSEN}; do echo -n "${v} ${v}/${myarch}${mythreading}"; done )
	[[ -n "${ABI}" ]] && myconf "-Dusrinc=$(get_ml_incdir)"

	[[ ${ELIBC} == "FreeBSD" ]] && myconf "-Dlibc=/usr/$(get_libdir)/libc.a"

	# Prefix: the host system needs not to follow Gentoo multilib stuff, and in
	# Prefix itself we don't do multilib either, so make sure perl can find
	# something compatible.
	if use prefix ; then
		myconf "-Dlibpth=${EPREFIX}/$(get_libdir) ${EPREFIX}/usr/$(get_libdir) /lib /usr/lib /lib64 /usr/lib64 /lib32 /usr/lib32"
	elif [[ $(get_libdir) != "lib" ]] ; then
		# We need to use " and not ', as the written config.sh use ' ...
		myconf "-Dlibpth=/usr/local/$(get_libdir) /$(get_libdir) /usr/$(get_libdir)"
	fi

	sh Configure \
		-des \
		-Duseshrplib \
		-Darchname="${myarch}" \
		-Dcc="$(tc-getCC)" \
		-Doptimize="${CFLAGS}" \
		-Dscriptdir="${EPREFIX}"/usr/bin \
		-Dprefix="${EPREFIX}"'/usr' \
		-Dvendorprefix="${EPREFIX}"'/usr' \
		-Dsiteprefix="${EPREFIX}"'/usr' \
		-Dprivlib="${EPREFIX}/usr/$(get_libdir)/perl5/${MY_PV}" \
		-Darchlib="${EPREFIX}/usr/$(get_libdir)/perl5/${MY_PV}/${myarch}${mythreading}" \
		-Dvendorlib="${EPREFIX}/usr/$(get_libdir)/perl5/vendor_perl/${MY_PV}" \
		-Dvendorarch="${EPREFIX}/usr/$(get_libdir)/perl5/vendor_perl/${MY_PV}/${myarch}${mythreading}" \
		-Dsitelib="${EPREFIX}/usr/$(get_libdir)/perl5/site_perl/${MY_PV}" \
		-Dsitearch="${EPREFIX}/usr/$(get_libdir)/perl5/site_perl/${MY_PV}/${myarch}${mythreading}" \
		-Dman1dir="${EPREFIX}"/usr/share/man/man1 \
		-Dman3dir="${EPREFIX}"/usr/share/man/man3 \
		-Dinstallman1dir="${EPREFIX}"/usr/share/man/man1 \
		-Dinstallman3dir="${EPREFIX}"/usr/share/man/man3 \
		-Dman1ext='1' \
		-Dman3ext='3pm' \
		-Dlibperl="${LIBPERL}" \
		-Dlocincpth="${EPREFIX}"'/usr/include ' \
		-Dglibpth="${EPREFIX}/$(get_libdir) ${EPREFIX}/usr/$(get_libdir)"' ' \
		-Duselargefiles \
		-Dd_semctl_semun \
		-Dinc_version_list="$inclist" \
		-Dcf_by='Gentoo' \
		-Dmyhostname='localhost' \
		-Dperladmin='${PORTAGE_ROOT_USER}@localhost' \
		-Dinstallusrbinperl='n' \
		-Ud_csh \
		-Uusenm \
		"${myconf[@]}" || die "Unable to configure"
}

src_test() {
#	use elibc_uclibc && export MAKEOPTS="${MAKEOPTS} -j1"
#	TEST_JOBS=$(echo -j1 ${MAKEOPTS} | sed -r 's/.*(-j[[:space:]]*|--jobs=)([[:digit:]]+).*/\2/' ) \
		make test_harness || die "test failed"
}

src_install() {
	export LC_ALL="C"
	local i
	local coredir="/usr/$(get_libdir)/perl5/${MY_PV}/${myarch}${mythreading}/CORE"

	# Fix for "stupid" modules and programs
	dodir /usr/$(get_libdir)/perl5/site_perl/${MY_PV}/${myarch}${mythreading}

	local installtarget=install
	if use build ; then
		installtarget=install.perl
	fi
	make DESTDIR="${D}" ${installtarget} || die "Unable to make ${installtarget}"

	rm -f "${ED}"/usr/bin/perl
	ln -s perl${MY_PV} "${ED}"/usr/bin/perl

	dolib.so "${ED}"/${coredir}/${LIBPERL} || die
	dosym ${LIBPERL} /usr/$(get_libdir)/libperl$(get_libname ${SHORT_PV}) || die
	dosym ${LIBPERL} /usr/$(get_libdir)/libperl$(get_libname) || die
	rm -f "${ED}"/${coredir}/${LIBPERL}
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/${LIBPERL}
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/libperl$(get_libname ${SHORT_PV})
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/libperl$(get_libname)

	rm -rf "${ED}"/usr/share/man/man3 || die "Unable to remove module man pages"
#	cp -f utils/h2ph utils/h2ph_patched
#	epatch "${FILESDIR}"/${PN}-h2ph-ansi-header.patch
#
#	LD_LIBRARY_PATH=. ./perl -Ilib utils/h2ph_patched \
#		-a -d "${ED}"/usr/$(get_libdir)/perl5/${MY_PV}/${myarch}${mythreading} <<EOF
#asm/termios.h
#syscall.h
#syslimits.h
#syslog.h
#sys/ioctl.h
#sys/socket.h
#sys/time.h
#wait.h
#EOF

# vvv still needed?
#	# This is to fix a missing c flag for backwards compat
#	for i in $(find "${ED}"/usr/$(get_libdir)/perl5 -iname "Config.pm" ) ; do
#		sed -i \
#			-e "s:ccflags=':ccflags='-DPERL5 :" \
#			-e "s:cppflags=':cppflags='-DPERL5 :" \
#			"${i}" || die "Sed failed"
#	done

	# A poor fix for the miniperl issues
	dosed 's:./miniperl:/usr/bin/perl:' /usr/$(get_libdir)/perl5/${MY_PV}/ExtUtils/xsubpp
	fperms 0444 /usr/$(get_libdir)/perl5/${MY_PV}/ExtUtils/xsubpp
	dosed 's:./miniperl:/usr/bin/perl:' /usr/bin/xsubpp
	fperms 0755 /usr/bin/xsubpp

	# This removes ${D} from Config.pm and .packlist
	for i in $(find "${D}" -iname "Config.pm" -o -iname ".packlist" ) ; do
		einfo "Removing ${D} from ${i}..."
		sed -i -e "s:${D}::" "${i}" || die "Sed failed"
	done

	# Note: find out from psm why we would need/want this.
	# ( use berkdb && has_version '=sys-libs/db-1*' ) ||
	#	find "${ED}" -name "*NDBM*" | xargs rm -f

	dodoc Changes* README AUTHORS || die

	if use doc ; then
		# HTML Documentation
		# We expect errors, warnings, and such with the following.

		dodir /usr/share/doc/${PF}/html
		./perl installhtml \
			--podroot='.' \
			--podpath='lib:ext:pod:vms' \
			--recurse \
			--htmldir="${ED}/usr/share/doc/${PF}/html" \
			--libpods='perlfunc:perlguts:perlvar:perlrun:perlop'
	fi

	dual_scripts

	if use build ; then
		src_remove_extra_files
	fi
}

pkg_postinst() {
	local INC DIR file

	dual_scripts

	INC=$(perl -e 'for $line (@INC) { next if $line eq "."; next if $line =~ m/'${MY_PV}'|etc|local|perl$/; print "$line\n" }')
	if [[ "${ROOT}" = "/" ]] ; then
		ebegin "Removing old .ph files"
		for DIR in ${INC} ; do
			if [[ -d "${ROOT}/${DIR}" ]] ; then
				for file in $(find "${ROOT}/${DIR}" -name "*.ph" -type f ) ; do
					rm -f "${ROOT}/${file}"
					einfo "<< ${file}"
				done
			fi
		done
		# Silently remove the now empty dirs
		for DIR in ${INC} ; do
			if [[ -d "${ROOT}/${DIR}" ]] ; then
				find "${ROOT}/${DIR}" -depth -type d -print0 | xargs -0 -r rmdir &> /dev/null
			fi
		done
		ebegin "Generating ConfigLocal.pm (ignore any error)"
		enc2xs -C
		ebegin "Converting C header files to the corresponding Perl format"
		cd "${EPREFIX}"/usr/include
		h2ph -Q *
		h2ph -Q -r sys/* arpa/* netinet/* bits/* security/* asm/* gnu/* linux/*
	fi

# This has been moved into a function because rumor has it that a future release
# of portage will allow us to check what version was just removed - which means
# we will be able to invoke this only as needed :)
	# Tried doing this via  -z, but $INC is too big...
	if [[ "${INC}x" != "x" ]]; then
		cleaner_msg
		epause 5
	fi
}

pkg_postrm(){
	${IS_PERL} && dual_scripts
}

cleaner_msg() {
	eerror "You have had multiple versions of perl. It is recommended"
	eerror "that you run perl-cleaner now. perl-cleaner will"
	eerror "assist with this transition. This script is capable"
	eerror "of cleaning out old .ph files, rebuilding modules for "
	eerror "your new version of perl, as well as re-emerging"
	eerror "applications that compiled against your old libperl$(get_libname)"
	eerror
	eerror "PLEASE DO NOT INTERRUPT THE RUNNING OF THIS SCRIPT."
	eerror "Part of the rebuilding of applications compiled against "
	eerror "your old libperl involves temporarily unmerging"
	eerror "them - interruptions could leave you with unmerged"
	eerror "packages before they can be remerged."
	eerror ""
	eerror "If you have run perl-cleaner and a package still gives"
	eerror "you trouble, and re-emerging it fails to correct"
	eerror "the problem, please check http://bugs.gentoo.org/"
	eerror "for more information or to report a bug."
	eerror ""
}

src_remove_dual_scripts() {
	local i pkg ver ff
	pkg="$1"
	ver="$2"
	shift 2
	if has "${EBUILD_PHASE:-none}" "postinst" "postrm" ;then
		for i in "$@" ; do
			ff=`echo ${EROOT}/usr/share/man/man1/${i}-${ver}-${P}.1*`
			ff=${ff##*.1}
			alternatives_auto_makesym "/usr/bin/${i}" "/usr/bin/${i}-[0-9]*"
			alternatives_auto_makesym "/usr/share/man/man1/${i}.1${ff}" "/usr/share/man/man1/${i}-[0-9]*"
		done
	elif has "${EBUILD_PHASE:-none}" "setup" ; then
		for i in "$@" ; do
			if [[ -f ${EROOT}/usr/bin/${i} && ! -h ${EROOT}/usr/bin/${i} ]] ; then
				has_version ${pkg} && ewarn "You must reinstall $pkg !"
				break
			fi
		done
	else
		for i in "$@" ; do
			mv "${ED}"/usr/bin/${i}{,-${ver}-${P}} || die
			mv "${ED}"/usr/share/man/man1/${i}{.1,-${ver}-${P}.1} || \
				echo "/usr/share/man/man1/${i}.1 does not exist!"
		done
	fi
}

src_remove_extra_files() {
	local prefix="./usr" # ./ is important
	local bindir="${prefix}/bin"
	local libdir="${prefix}/$(get_libdir)"
	local perlroot="${libdir}/perl5" # perl installs per-arch dirs
	local prV="${perlroot}/${MY_PV}"
	local prVA="${prV}/${myarch}${mythreading}"

	# I made this list from the Mandr*, Debian and ex-Connectiva perl-base list
	# Then, I added several files to get GNU autotools running
	# FIXME: should this be in a separated file to be sourced?
	local MINIMAL_PERL_INSTALL="
	${bindir}/h2ph
	${bindir}/perl
	${bindir}/perl${MY_PV}
	${bindir}/pod2man
	${libdir}/${LIBPERL}
	${libdir}/libperl$(get_libname)
	${libdir}/libperl$(get_libname ${SHORT_PV})
	${prV}/attributes.pm
	${prV}/AutoLoader.pm
	${prV}/autouse.pm
	${prV}/base.pm
	${prV}/bigint.pm
	${prV}/bignum.pm
	${prV}/bigrat.pm
	${prV}/blib.pm
	${prV}/bytes_heavy.pl
	${prV}/bytes.pm
	${prV}/Carp/Heavy.pm
	${prV}/Carp.pm
	${prV}/charnames.pm
	${prV}/Class/Struct.pm
	${prV}/constant.pm
	${prV}/diagnostics.pm
	${prV}/DirHandle.pm
	${prV}/Exporter/Heavy.pm
	${prV}/Exporter.pm
	${prV}/ExtUtils/Command.pm
	${prV}/ExtUtils/Constant.pm
	${prV}/ExtUtils/Embed.pm
	${prV}/ExtUtils/Installed.pm
	${prV}/ExtUtils/Install.pm
	${prV}/ExtUtils/Liblist.pm
	${prV}/ExtUtils/MakeMaker.pm
	${prV}/ExtUtils/Manifest.pm
	${prV}/ExtUtils/Mkbootstrap.pm
	${prV}/ExtUtils/Mksymlists.pm
	${prV}/ExtUtils/MM_Any.pm
	${prV}/ExtUtils/MM_MacOS.pm
	${prV}/ExtUtils/MM.pm
	${prV}/ExtUtils/MM_Unix.pm
	${prV}/ExtUtils/MY.pm
	${prV}/ExtUtils/Packlist.pm
	${prV}/ExtUtils/testlib.pm
	${prV}/ExtUtils/Miniperl.pm
	${prV}/ExtUtils/Command/MM.pm
	${prV}/ExtUtils/Constant/Base.pm
	${prV}/ExtUtils/Constant/Utils.pm
	${prV}/ExtUtils/Constant/XS.pm
	${prV}/ExtUtils/Liblist/Kid.pm
	${prV}/ExtUtils/MakeMaker/bytes.pm
	${prV}/ExtUtils/MakeMaker/vmsish.pm
	${prV}/fields.pm
	${prV}/File/Basename.pm
	${prV}/File/Compare.pm
	${prV}/File/Copy.pm
	${prV}/File/Find.pm
	${prV}/FileHandle.pm
	${prV}/File/Path.pm
	${prV}/File/Spec.pm
	${prV}/File/Spec/Unix.pm
	${prV}/File/stat.pm
	${prV}/filetest.pm
	${prVA}/attrs.pm
	${prVA}/auto/attrs
	${prVA}/auto/Cwd/Cwd$(get_libname)
	${prVA}/auto/Data/Dumper/Dumper$(get_libname)
	${prVA}/auto/DynaLoader/dl_findfile.al
	${prVA}/auto/Fcntl/Fcntl$(get_libname)
	${prVA}/auto/File/Glob/Glob$(get_libname)
	${prVA}/auto/IO/IO$(get_libname)
	${prVA}/auto/POSIX/autosplit.ix
	${prVA}/auto/POSIX/fstat.al
	${prVA}/auto/POSIX/load_imports.al
	${prVA}/auto/POSIX/POSIX.bs
	${prVA}/auto/POSIX/POSIX$(get_libname)
	${prVA}/auto/POSIX/stat.al
	${prVA}/auto/POSIX/tmpfile.al
	${prVA}/auto/re/re$(get_libname)
	${prVA}/auto/Socket/Socket$(get_libname)
	${prVA}/auto/Storable/autosplit.ix
	${prVA}/auto/Storable/_retrieve.al
	${prVA}/auto/Storable/retrieve.al
	${prVA}/auto/Storable/Storable$(get_libname)
	${prVA}/auto/Storable/_store.al
	${prVA}/auto/Storable/store.al
	${prVA}/B/Deparse.pm
	${prVA}/B.pm
	${prVA}/Config.pm
	${prVA}/Config_heavy.pl
	${prVA}/CORE/libperl$(get_libname)
	${prVA}/Cwd.pm
	${prVA}/Data/Dumper.pm
	${prVA}/DynaLoader.pm
	${prVA}/encoding.pm
	${prVA}/Errno.pm
	${prVA}/Fcntl.pm
	${prVA}/File/Glob.pm
	${prVA}/_h2ph_pre.ph
	${prVA}/IO/File.pm
	${prVA}/IO/Handle.pm
	${prVA}/IO/Pipe.pm
	${prVA}/IO.pm
	${prVA}/IO/Seekable.pm
	${prVA}/IO/Select.pm
	${prVA}/IO/Socket.pm
	${prVA}/lib.pm
	${prVA}/NDBM_File.pm
	${prVA}/ops.pm
	${prVA}/POSIX.pm
	${prVA}/re.pm
	${prVA}/Socket.pm
	${prVA}/Storable.pm
	${prVA}/threads
	${prVA}/threads.pm
	${prVA}/XSLoader.pm
	${prV}/Getopt/Long.pm
	${prV}/Getopt/Std.pm
	${prV}/if.pm
	${prV}/integer.pm
	${prV}/IO/Socket/INET.pm
	${prV}/IO/Socket/UNIX.pm
	${prV}/IPC/Open2.pm
	${prV}/IPC/Open3.pm
	${prV}/less.pm
	${prV}/List/Util.pm
	${prV}/locale.pm
	${prV}/open.pm
	${prV}/overload.pm
	${prV}/Pod/InputObjects.pm
	${prV}/Pod/Man.pm
	${prV}/Pod/ParseLink.pm
	${prV}/Pod/Parser.pm
	${prV}/Pod/Select.pm
	${prV}/Pod/Text.pm
	${prV}/Pod/Usage.pm
	${prV}/PerlIO.pm
	${prV}/Scalar/Util.pm
	${prV}/SelectSaver.pm
	${prV}/sigtrap.pm
	${prV}/sort.pm
	${prV}/stat.pl
	${prV}/strict.pm
	${prV}/subs.pm
	${prV}/Symbol.pm
	${prV}/Text/ParseWords.pm
	${prV}/Text/Tabs.pm
	${prV}/Text/Wrap.pm
	${prV}/Time/Local.pm
	${prV}/unicore/Canonical.pl
	${prV}/unicore/Exact.pl
	${prV}/unicore/lib/gc_sc/Digit.pl
	${prV}/unicore/lib/gc_sc/Word.pl
	${prV}/unicore/PVA.pl
	${prV}/unicore/To/Fold.pl
	${prV}/unicore/To/Lower.pl
	${prV}/unicore/To/Upper.pl
	${prV}/utf8_heavy.pl
	${prV}/utf8.pm
	${prV}/vars.pm
	${prV}/vmsish.pm
	${prV}/warnings
	${prV}/warnings.pm
	${prV}/warnings/register.pm"

	pushd "${ED}" > /dev/null
	# Remove cruft
	einfo "Removing files that are not in the minimal install"
	echo "${MINIMAL_PERL_INSTALL}"
	for f in $(find . -type f ) ; do
		has "${f}" ${MINIMAL_PERL_INSTALL} || rm -f "${f}"
	done
	# Remove empty directories
	find . -depth -type d -print0 | xargs -0 -r rmdir &> /dev/null
	popd > /dev/null
}
