# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/perl/perl-5.8.8-r6.ebuild,v 1.4 2009/05/08 05:46:34 tove Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

# The slot of this binary compat version of libperl.so
PERLSLOT="1"

SHORT_PV="${PV%.*}"
MY_P="perl-${PV/_rc/-RC}"
MY_PV="${PV%_rc*}"
DESCRIPTION="Larry Wall's Practical Extraction and Report Language"
S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://cpan/src/${MY_P}.tar.bz2"
HOMEPAGE="http://www.perl.org/"
LIBPERL="libperl$(get_libname ${PERLSLOT}.${SHORT_PV})"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="berkdb debug doc gdbm ithreads perlsuid build elibc_FreeBSD"
PERL_OLDVERSEN="5.8.0 5.8.2 5.8.4 5.8.5 5.8.6 5.8.7"

DEPEND="berkdb? ( sys-libs/db )
	gdbm? ( >=sys-libs/gdbm-1.8.3 )
	!m68k-mint? ( >=sys-devel/libperl-${PV}-r1 )
	!prefix? ( elibc_FreeBSD? ( sys-freebsd/freebsd-mk-defs ) )
	!m68k-mint? ( <sys-devel/libperl-5.9 )
	!<perl-core/File-Spec-0.87
	!<perl-core/Test-Simple-0.47-r1"

RDEPEND="!m68k-mint? ( ~sys-devel/libperl-${PV} )
	berkdb? ( sys-libs/db )
	gdbm? ( >=sys-libs/gdbm-1.8.3 )
	build? (
		!perl-core/Test-Harness
		!perl-core/PodParser
		!dev-perl/Locale-gettext
	)"

PDEPEND=">=app-admin/perl-cleaner-1.03
		!build? (
			>=perl-core/PodParser-1.32
			>=perl-core/Test-Harness-2.56
		)"

pkg_setup() {
	# I think this should rather be displayed if you *have* 'ithreads'
	# in USE if it could break things ...
	if use ithreads
	then
		ewarn "PLEASE NOTE: You are compiling ${MY_P} with"
		ewarn "interpreter-level threading enabled."
		ewarn "Threading is not supported by all applications "
		ewarn "that compile against perl. You use threading at "
		ewarn "your own discretion. "
		epause 5
	fi

	if [[ ${CHOST} != *-mint* && ! -f "${EROOT}/usr/$(get_libdir)/${LIBPERL}" ]]
	then
		# Make sure we have libperl installed ...
		eerror "Cannot find ${EROOT}/usr/$(get_libdir)/${LIBPERL}!  Make sure that you"
		eerror "have sys-libs/libperl installed properly ..."
		die "Cannot find ${EROOT}/usr/$(get_libdir)/${LIBPERL}!"
	fi
}

src_unpack() {
	unpack ${A}

	# MiNT patch
	cd ${S}; epatch ${FILESDIR}/${P}-mint.patch

	# Get -lpthread linked before -lc.  This is needed
	# when using glibc >= 2.3, or else runtime signal
	# handling breaks.  Fixes bug #14380.
	# <rac@gentoo.org> (14 Feb 2003)
	# reinstated to try to avoid sdl segfaults 03.10.02
	cd "${S}"; epatch "${FILESDIR}"/${PN}-prelink-lpthread.patch

	# Patch perldoc to not abort when it attempts to search
	# nonexistent directories; fixes bug #16589.
	# <rac@gentoo.org> (28 Feb 2003)

	cd "${S}"; epatch "${FILESDIR}"/${PN}-perldoc-emptydirs.patch

	# this lays the groundwork for solving the issue of what happens
	# when people (or ebuilds) install different versiosn of modules
	# that are in the core, by rearranging the @INC directory to look
	# site -> vendor -> core.
	cp "${FILESDIR}"/${P}-reorder-INC.patch "${T}"/
	sed -i -e 's:"/etc/perl":"'"${EPREFIX}"'/etc/perl":' "${T}"/${P}-reorder-INC.patch
	cd "${S}"; epatch "${T}"/${P}-reorder-INC.patch

	# some well-intentioned stuff in http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&selm=Pine.SOL.4.10.10205231231200.5399-100000%40maxwell.phys.lafayette.edu
	# attempts to avoid bringing cccdlflags to bear on static
	# extensions (like DynaLoader).  i believe this is
	# counterproductive on a Gentoo system which has both a shared
	# and static libperl, so effectively revert this here.
	cd "${S}"; epatch "${FILESDIR}"/${PN}-picdl.patch

	# Configure makes an unwarranted assumption that /bin/ksh is a
	# good shell. This patch makes it revert to using /bin/sh unless
	# /bin/ksh really is executable. Should fix bug 42665.
	# rac 2004.06.09
	cd "${S}"; epatch "${FILESDIR}"/${PN}-noksh.patch

	# makedepend.SH contains a syntax error which is ignored by bash but causes
	# dash to abort
	epatch "${FILESDIR}"/${P}-makedepend-syntax.patch

	# We do not want the build root in the linked perl module's RUNPATH, so
	# strip paths containing PORTAGE_TMPDIR if its set.  This is for the
	# MakeMaker module, bug #105054.
	epatch "${FILESDIR}"/${PN}-5.8.7-MakeMaker-RUNPATH.patch

	# Starting and hopefully ending with 5.8.7 we observe stack
	# corruption with the regexp handling in perls DynaLoader code
	# with ssp enabled. This become fatal during compile time so we
	# temporally disable ssp on two regexp files till upstream has a
	# chance to work it out. Bug #97452
	[[ -n $(test-flags -fno-stack-protector) ]] && \
		epatch "${FILESDIR}"/${PN}-regexp-nossp.patch

	# On PA7200, uname -a contains a single quote and we need to
	# filter it otherwise configure fails. See #125535.
	epatch "${FILESDIR}"/perl-hppa-pa7200-configure.patch

	epatch "${FILESDIR}"/${P}-aix.patch
	epatch "${FILESDIR}"/${P}-hpux.patch
	epatch "${FILESDIR}"/${P}-solaris-64bit.patch # may clash with native linker
	epatch "${FILESDIR}"/${P}-solaris-relocation.patch
	epatch "${FILESDIR}"/${P}-solaris11.patch
	epatch "${FILESDIR}"/${P}-irix.patch
	epatch "${FILESDIR}"/${PN}-cleanup-paths.patch
	epatch "${FILESDIR}"/${P}-usr-local.patch

	# activate Solaris 11 workaround...
	[[ ${CHOST} == *-solaris2.11 ]] && append-flags -DSOLARIS11

	case "$(get_libdir)" in
		lib64) cd "${S}" && epatch "${FILESDIR}"/${P}-lib64.patch;;
		lib32) cd "${S}" && epatch "${FILESDIR}"/${P}-lib32.patch;;
		lib) true;;
		*) die "Something's wrong with your libdir, don't know how to treat it.";;
	esac

	[[ ${CHOST} == *-dragonfly* ]] && cd ${S} && epatch "${FILESDIR}"/${P}-dragonfly-clean.patch
	[[ ${CHOST} == *-freebsd* ]] && cd ${S} && epatch "${FILESDIR}"/${P}-fbsdhints.patch
	cd ${S}; epatch "${FILESDIR}"/${P}-USE_MM_LD_RUN_PATH.patch
	cd ${S}; epatch "${FILESDIR}"/${P}-links.patch
	# c++ patch - should address swig related items
	cd ${S}; epatch "${FILESDIR}"/${P}-cplusplus.patch

	epatch "${FILESDIR}"/${P}-gcc42-command-line.patch

	# Newer linux-headers don't include asm/page.h. Fix this.
	# Patch from bug 168312, thanks Peter!
	# Cannot test for '>sys-kernel/linux-headers-2.6.20' in prefix,
	# so try to compile snippet in question instead.
	cat > "${T}"/test-asm-page.c <<-EOF
		#ifdef __linux__
		#include <asm/page.h>
		#endif
	EOF
	$(tc-getCC) -o "${T}"/test-asm-page.o -c "${T}"/test-asm-page.c >& /dev/null \
	|| epatch "${FILESDIR}"/${P}-asm-page-h-compile-failure.patch

	# Also add the directory prefix of the current file when the quote syntax is
	# used; 'require' will only look in @INC, not the current directory.
	epatch "${FILESDIR}"/${PN}-fix_h2ph_include_quote.patch

	# perlcc fix patch - bug #181229
	epatch "${FILESDIR}"/${P}-perlcc.patch

	# patch to fix bug #198196
	# UTF/Regular expressions boundary error (CVE-2007-5116)
	epatch "${FILESDIR}"/${P}-utf8-boundary.patch

	# patch to fix bug #219203
	epatch "${FILESDIR}"/${P}-CVE-2008-1927.patch

	epatch "${FILESDIR}"/${P}-CAN-2005-0448-rmtree-2.patch

	# on interix, $firstmakefile may not be 'makefile', since the
	# filesystem may be case insensitive, and perl will wrongly
	# delete Makefile.
	epatch "${FILESDIR}"/${P}-interix-firstmakefile.patch
	epatch "${FILESDIR}"/${P}-interix-misc.patch

	# perl tries to link against gdbm if present, even without USE=gdbm
	if ! use gdbm; then
		sed -i '/^libswanted=/s/gdbm //' Configure
	fi
}

myconf() {
	# the myconf array is declared in src_configure
	myconf=( "${myconf[@]}" "$@" )
}

src_configure() {
	declare -a myconf

	# some arches and -O do not mix :)
	use arm && replace-flags -O? -O1
	use ppc && replace-flags -O? -O1
	use ia64 && replace-flags -O? -O1
	# Perl has problems compiling with -Os in your flags with glibc
	use elibc_uclibc || replace-flags "-Os" "-O2"
	( gcc-specs-ssp && use ia64 ) && append-flags -fno-stack-protector
	# This flag makes compiling crash in interesting ways
	filter-flags -malign-double
	# Fixes bug #97645
	use ppc && filter-flags -mpowerpc-gpopt
	# Fixes bug #143895 on gcc-4.1.1
	filter-flags "-fsched2-use-superblocks"

	export LC_ALL="C"

	case ${CHOST} in
		*-freebsd*) osname="freebsd" ;;
		*-dragonfly*) osname="dragonfly" ;;
		*-netbsd*) osname="netbsd" ;;
		*-openbsd*) osname="openbsd" ;;
		*-darwin*) osname="darwin" ;;
		*-solaris*)
			osname="solaris"
			# solaris2.9 has /lib/libgdbm.so.2 and /lib/libgdbm.so.3,
			# but no linkable /lib/libgdbm.so.
			# This might apply to others too, but seen on solaris only yet.
			myconf -Dignore_versioned_solibs
			;;
		*-aix*) osname="aix" ;;
		*-hpux*) osname="hpux" ;;
		*-irix*)
			osname="irix"
			myconf -Dcc="cc -n32 -mips4"
			use ithreads && myconf -Dlibs="-lm -lpthread" || myconf -Dlibs="-lm"
			;;
		*-interix*) osname='interix' ;;
		*-mint*) osname="freemint" ;;

		*) osname="linux" ;;
	esac

	case ${CHOST} in
		*-irix*)
		myconf -Dccdlflags='-exports'
		;;
	*)
		myconf -Dccdlflags='-rdynamic'
		;;
	esac

	if use ithreads
	then
		einfo "using ithreads"
		mythreading="-multi"
		myconf -Dusethreads
		myarch=${CHOST}
		myarch="${myarch%%-*}-${osname}-thread"
	else
		myarch=${CHOST}
		myarch="${myarch%%-*}-${osname}"
	fi

	local inclist=$(for v in $PERL_OLDVERSEN; do echo -n "$v $v/$myarch$mythreading "; done)

	# allow either gdbm to provide ndbm (in <gdbm/ndbm.h>) or db1

	myndbm='U'
	mygdbm='U'
	mydb='U'

	if use gdbm
	then
		mygdbm='D'
		myndbm='D'
	fi
	if use berkdb
	then
		mydb='D'
		has_version '=sys-libs/db-1*' && myndbm='D'
	fi

	myconf "-${myndbm}i_ndbm" "-${mygdbm}i_gdbm" "-${mydb}i_db"

	if use mips
	then
		# this is needed because gcc 3.3-compiled kernels will hang
		# the machine trying to run this test - check with `Kumba
		# <rac@gentoo.org> 2003.06.26
		myconf -Dd_u32align
	fi

	if use perlsuid
	then
		myconf -Dd_dosuid
		ewarn "You have enabled Perl's suid compile. Please"
		ewarn "read http://search.cpan.org/~nwclark/perl-5.8.8/INSTALL#suidperl"
		epause 3
	fi

	if use debug
	then
		CFLAGS="${CFLAGS} -g"
		myconf -DDEBUGGING
	fi

	if use sparc
	then
		myconf -Ud_longdbl
	fi

	if use alpha && "$(tc-getCC)" == "ccc"
	then
		ewarn "Perl will not be built with berkdb support, use gcc if you needed it..."
		myconf -Ui_db -Ui_ndbm
	fi

	[[ -n "${ABI}" ]] && myconf "-Dusrinc=$(get_ml_incdir)"

	[[ ${ELIBC} == "FreeBSD" ]] && myconf "-Dlibc=/usr/$(get_libdir)/libc.a"

	# We need to use " and not ', as the written config.sh use ' ...
	# Prefix: the host system needs not to follow Gentoo multilib stuff, and in
	# Prefix itself we don't do multilib either, so make sure perl can find
	# something compatible.
	myconf "-Dlibpth=${EPREFIX}/$(get_libdir) ${EPREFIX}/usr/$(get_libdir) /lib /usr/lib /lib64 /usr/lib64 /lib32 /usr/lib32"

	[[ -n "${LDFLAGS}" ]] && myconf -Dldflags="${LDFLAGS}"

		sh Configure -des \
		-Darchname="${myarch}" \
		-Dcccdlflags='-fPIC' \
		-Dcc="$(tc-getCC)" \
		-Dprefix="${EPREFIX}"'/usr' \
		-Dvendorprefix="${EPREFIX}"'/usr' \
		-Dsiteprefix="${EPREFIX}"'/usr' \
		-Dlocincpth="${EPREFIX}"'/usr/include ' \
		-Dglibpth="${EPREFIX}/$(get_libdir) ${EPREFIX}/usr/$(get_libdir)"' ' \
		-Doptimize="${CFLAGS}" \
		-Duselargefiles \
		-Dd_semctl_semun \
		-Dscriptdir="${EPREFIX}"/usr/bin \
		-Dman1dir="${EPREFIX}"/usr/share/man/man1 \
		-Dman3dir="${EPREFIX}"/usr/share/man/man3 \
		-Dinstallman1dir="${ED}"/usr/share/man/man1 \
		-Dinstallman3dir="${ED}"/usr/share/man/man3 \
		-Dman1ext='1' \
		-Dman3ext='3pm' \
		-Dinc_version_list="$inclist" \
		-Dcf_by='Gentoo' \
		-Ud_csh \
		-Dusenm \
		"${myconf[@]}" || die "Unable to configure"
}

src_compile() {

	# would like to bracket this with a test for the existence of a
	# dotfile, but can't clean it automatically now.

	src_configure

	emake -j1 -f Makefile depend || die "Couldn't make depends"
	emake -j1 || die "Unable to make"
}

src_test() {
	use elibc_uclibc && export MAKEOPTS="${MAKEOPTS} -j1"
	emake -i test CCDLFLAGS= || die "test failed"
}

src_install() {

	export LC_ALL="C"

	# Need to do this, else apps do not link to dynamic version of
	# the library ...
	local coredir="/usr/$(get_libdir)/perl5/${MY_PV}/${myarch}${mythreading}/CORE"
	dodir ${coredir}
	# for AIX and FreeMiNT
	if [[ $(get_libname) != .a && $(get_libname) != .irrelevant ]] ; then
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/${LIBPERL}
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/libperl$(get_libname ${PERLSLOT})
	dosym ../../../../../$(get_libdir)/${LIBPERL} ${coredir}/libperl$(get_libname)
	fi

	# Fix for "stupid" modules and programs
	dodir /usr/$(get_libdir)/perl5/site_perl/${MY_PV}/${myarch}${mythreading}

	local installtarget=install
	if use build ; then
		installtarget=install.perl
	fi
	make DESTDIR="${D}" ${installtarget} || die "Unable to make ${installtarget}"

	rm "${ED}"/usr/bin/perl
	ln -s perl${MY_PV} "${ED}"/usr/bin/perl

	cp -f utils/h2ph utils/h2ph_patched
	epatch "${FILESDIR}"/${PN}-h2ph-ansi-header.patch

	LD_LIBRARY_PATH=. ./perl -Ilib utils/h2ph_patched \
		-a -d "${ED}"/usr/$(get_libdir)/perl5/${MY_PV}/${myarch}${mythreading} <<EOF
asm/termios.h
syscall.h
syslimits.h
syslog.h
sys/ioctl.h
sys/socket.h
sys/time.h
wait.h
EOF

	# This is to fix a missing c flag for backwards compat
	for i in `find "${ED}"/usr/$(get_libdir)/perl5 -iname "Config.pm"`;do
		sed -e "s:ccflags=':ccflags='-DPERL5 :" \
			-e "s:cppflags=':cppflags='-DPERL5 :" \
			${i} > ${i}.new &&\
			mv -f ${i}.new ${i} || die "Sed failed"
	done

	# A poor fix for the miniperl issues
	fperms 0644 /usr/$(get_libdir)/perl5/${MY_PV}/ExtUtils/xsubpp
	dosed 's:./miniperl:/usr/bin/perl:' /usr/$(get_libdir)/perl5/${MY_PV}/ExtUtils/xsubpp
	fperms 0444 /usr/$(get_libdir)/perl5/${MY_PV}/ExtUtils/xsubpp
	dosed 's:./miniperl:/usr/bin/perl:' /usr/bin/xsubpp
	fperms 0755 /usr/bin/xsubpp

	# This removes ${ED} from Config.pm and .packlist
	for i in `find "${ED}" -iname "Config.pm"` `find "${ED}" -iname ".packlist"`;do
		einfo "Removing ${ED} from ${i}..."
		sed -e "s:${ED}::" ${i} > ${i}.new &&\
			mv ${i}.new ${i} || die "Sed failed"
	done

	# Note: find out from psm why we would need/want this.
	# ( use berkdb && has_version '=sys-libs/db-1*' ) ||
	#	find ${ED} -name "*NDBM*" | xargs rm -f

	dodoc Changes* Artistic Copying README Todo* AUTHORS

	if use doc
	then
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
	cd `find "${ED}" -name Path.pm|sed -e 's/Path.pm//'`
	# CAN patch in bug 79685
	cd "${S}"
	#epatch "${FILESDIR}"/${P}-CAN-2005-0448-rmtree.patch

	# Remove those items we PDPEND on
	rm -f "${ED}"/usr/bin/pod2usage
	rm -f "${ED}"/usr/bin/podchecker
	rm -f "${ED}"/usr/bin/podselect
	rm -f "${ED}"/usr/bin/prove
	rm -f "${ED}"/usr/share/man/man1/pod2usage*
	rm -f "${ED}"/usr/share/man/man1/podchecker*
	rm -f "${ED}"/usr/share/man/man1/podselect*
	rm -f "${ED}"/usr/share/man/man1/prove*
	if use build ; then
		src_remove_extra_files
	fi

	# avoid problems with static archives that portage cannot write to
	find ${ED} -name "*.a" | xargs chmod 644
}

src_remove_extra_files()
{
	local prefix="./usr" # ./ is important
	local bindir="${prefix}/bin"
	local perlroot="${prefix}/$(get_libdir)/perl5" # perl installs per-arch dirs
	local prV="${perlroot}/${MY_PV}"
	# myarch and mythreading are defined inside src_configure()
	local prVA="${prV}/${myarch}${mythreading}"

	# I made this list from the Mandr*, Debian and ex-Connectiva perl-base list
	# Then, I added several files to get GNU autotools running
	# FIXME: should this be in a separated file to be sourced?
	local MINIMAL_PERL_INSTALL="
	${bindir}/h2ph
	${bindir}/perl
	${bindir}/perl${MY_PV}
	${bindir}/pod2man
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
	${prVA}/auto/POSIX/assert.al
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

	if use perlsuid ; then
		MINIMAL_PERL_INSTALL="${MINIMAL_PERL_INSTALL}
		${bindir}/suidperl
		${bindir}/sperl${MY_PV}"
	fi

	pushd "${ED}" > /dev/null
	# Remove cruft
	einfo "Removing files that are not in the minimal install"
	echo "${MINIMAL_PERL_INSTALL}"
	for f in $(find . -type f); do
		has ${f} ${MINIMAL_PERL_INSTALL} || rm -f ${f}
	done
	# Remove empty directories
	find . -depth -type d | xargs -r rmdir &> /dev/null
	popd > /dev/null
}

pkg_postinst() {
	INC=$(perl -e 'for $line (@INC) { next if $line eq "."; next if $line =~ m/'${MY_PV}'|etc|local|perl$/; print "$line\n" }')
	if [[ "${ROOT}" = "/" ]]
	then
		ebegin "Removing old .ph files"
		for DIR in $INC; do
			if [[ -d "${EROOT}"/$DIR ]]; then
				for file in $(find "${EROOT}"/$DIR -name "*.ph" -type f); do
					rm "${EROOT}"/$file
					einfo "<< $file"
				done
			fi
		done
		# Silently remove the now empty dirs
		for DIR in $INC; do
		   if [[ -d "${EROOT}"/$DIR ]]; then
			find "${EROOT}"/$DIR -depth -type d | xargs -r rmdir &> /dev/null
		   fi
		done
		ebegin "Generating ConfigLocal.pm (ignore any error)"
		enc2xs -C
		ebegin "Converting C header files to the corresponding Perl format"
		cd /usr/include;
		h2ph *
		h2ph -r sys/* arpa/* netinet/* bits/* security/* asm/* gnu/* linux/* gentoo*
		cd /usr/include/linux && h2ph *
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
	eerror ""

}
