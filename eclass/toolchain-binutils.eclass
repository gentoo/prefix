# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/toolchain-binutils.eclass,v 1.70 2007/01/07 05:51:21 vapier Exp $

# We install binutils into CTARGET-VERSION specific directories.  This lets
# us easily merge multiple versions for multiple targets (if we wish) and
# then switch the versions on the fly (with `binutils-config`).
#
# binutils-9999           -> live cvs
# binutils-9999_preYYMMDD -> nightly snapshot date YYMMDD
# binutils-#              -> normal release

extra_eclass=""
if [[ -n ${BINUTILS_TYPE} ]] ; then
	BTYPE=${BINUTILS_TYPE}
else
	case ${PV} in
	9999)      BTYPE="cvs";;
	9999_pre*) BTYPE="snap";;
	*)         BTYPE="rel";;
	esac
fi

if [[ ${BTYPE} == "cvs" ]] ; then
	extra_eclass="cvs"
	ECVS_SERVER="sourceware.org:/cvs/src"
	ECVS_MODULE="binutils"
	ECVS_USER="anoncvs"
	ECVS_PASS="anoncvs"
	BVER="cvs"
elif [[ ${BTYPE} == "snap" ]] ; then
	BVER=${PV/9999_pre}
elif [[ ${BTYPE} == "rel" ]] ; then
	BVER=${PV}
else
	BVER=${BINUTILS_VER}
fi

inherit eutils libtool flag-o-matic gnuconfig multilib ${extra_eclass}
EXPORT_FUNCTIONS src_unpack src_compile src_test src_install pkg_postinst pkg_postrm

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

DESCRIPTION="Tools necessary to build programs"
HOMEPAGE="http://sources.redhat.com/binutils/"

case ${BTYPE} in
	cvs)  SRC_URI="";;
	snap) SRC_URI="ftp://gcc.gnu.org/pub/binutils/snapshots/binutils-${BVER}.tar.bz2";;
	rel)
		SRC_URI="mirror://kernel/linux/devel/binutils/binutils-${PV}.tar.bz2
			mirror://kernel/linux/devel/binutils/test/binutils-${PV}.tar.bz2
			mirror://gnu/binutils/binutils-${PV}.tar.bz2"
esac
[[ -n ${PATCHVER} ]] && \
	SRC_URI="${SRC_URI} mirror://gentoo/binutils-${PV}-patches-${PATCHVER}.tar.bz2"
[[ -n ${UCLIBC_PATCHVER} ]] && \
	SRC_URI="${SRC_URI} mirror://gentoo/binutils-${PV}-uclibc-patches-${UCLIBC_PATCHVER}.tar.bz2"
[[ -n ${ELF2FLT_VER} ]] && \
	SRC_URI="${SRC_URI} mirror://gentoo/elf2flt-${ELF2FLT_VER}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 )"
IUSE="nls multitarget multislot test vanilla"
if use multislot ; then
	SLOT="${CTARGET}-${BVER}"
elif is_cross ; then
	SLOT="${CTARGET}"
else
	SLOT="0"
fi

if is_cross ; then
	RDEPEND=">=sys-devel/binutils-config-1.9"
else
	RDEPEND=">=sys-devel/binutils-config-1.8-r6"
fi
DEPEND="${RDEPEND}
	test? ( dev-util/dejagnu )
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/binutils
[[ ${BVER} != "cvs" ]] && S=${S}-${BVER}

LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${BVER}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${BVER}
MY_BUILDDIR=${WORKDIR}/build
if is_cross ; then
	BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}
else
	BINPATH=/usr/${CTARGET}/binutils-bin/${BVER}
fi

tc-binutils_unpack() {
	unpack ${A}
	mkdir -p "${MY_BUILDDIR}"
	[[ -d ${WORKDIR}/patch ]] && mkdir "${WORKDIR}"/patch/skip
}

tc-binutils_apply_patches() {
	cd "${S}"

	if ! use vanilla && [[ -n ${PATCHVER} ]] ; then
		EPATCH_SOURCE=${WORKDIR}/patch
		[[ -n $(ls "${EPATCH_SOURCE}"/*.bz2 2>/dev/null) ]] \
			&& EPATCH_SUFFIX="patch.bz2" \
			|| EPATCH_SUFFIX="patch"
		epatch
	fi
	if ! use vanilla && [[ -n ${UCLIBC_PATCHVER} ]] ; then
		EPATCH_SOURCE=${WORKDIR}/uclibc-patches
		[[ -n $(ls "${EPATCH_SOURCE}"/*.bz2 2>/dev/null) ]] \
			&& EPATCH_SUFFIX="patch.bz2" \
			|| EPATCH_SUFFIX="patch"
		EPATCH_MULTI_MSG="Applying uClibc fixes ..." \
		epatch
	elif [[ ${CTARGET} == *-uclibc ]] ; then
		die "sorry, but this binutils doesn't yet support uClibc :("
	fi

	# fix locale issues if possible #122216
	if [[ -e ${FILESDIR}/binutils-configure-LANG.patch ]] ; then
		einfo "Fixing misc issues in configure files"
		for f in $(grep -l 'autoconf version 2.13' $(find "${S}" -name configure)) ; do
			ebegin "  Updating ${f/${S}\/}"
			patch "${f}" "${FILESDIR}"/binutils-configure-LANG.patch >& "${T}"/configure-patch.log \
				|| eerror "Please file a bug about this"
			eend $?
		done
	fi

	# Fix po Makefile generators
	sed -i \
		-e '/^datadir = /s:$(prefix)/@DATADIRNAME@:@datadir@:' \
		-e '/^gnulocaledir = /s:$(prefix)/share:$(datadir):' \
		*/po/Make-in || die "sed po's failed"

	# Run misc portage update scripts
	gnuconfig_update
	elibtoolize --portage --no-uclibc
}

toolchain-binutils_src_unpack() {
	is_cross && [[ $(binutils-config -V) != binutils-config-1.9* ]] \
		&& die "You need to upgrade your binutils-config to 1.9 or newer"

	tc-binutils_unpack
	tc-binutils_apply_patches
}

toolchain-binutils_src_compile() {
	# make sure we filter $LINGUAS so that only ones that
	# actually work make it through #42033
	strip-linguas -u */po

	# keep things sane
	strip-flags

	local x
	echo
	for x in CATEGORY CBUILD CHOST CTARGET CFLAGS LDFLAGS ; do
		einfo "$(printf '%10s' ${x}:) ${!x}"
	done
	echo

	cd "${MY_BUILDDIR}"
	local myconf=""
	use nls \
		&& myconf="${myconf} --without-included-gettext" \
		|| myconf="${myconf} --disable-nls"
	[[ ${CHOST} == *"-solaris"* ]] && use nls && append-flags -lintl
	use multitarget && myconf="${myconf} --enable-targets=all"
	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"
	is_cross && myconf="${myconf} --with-sysroot=${EPREFIX}/usr/${CTARGET}"
	[[ ${EPREFIX%/} != "" ]] && myconf="${myconf} \
		--with-lib-path=${EPREFIX}/lib64:${EPREFIX}/usr/lib64:${EPREFIX}/lib:${EPREFIX}/usr/lib:/lib64:/usr/lib64:/lib:/usr/lib"
#	glibc-2.3.6 lacks support for this ...
#		--enable-secureplt   <- this is an alpha-only option
	myconf="--prefix=${EPREFIX}/usr \
		--host=${CHOST} \
		--target=${CTARGET} \
		--datadir=${EPREFIX}${DATAPATH} \
		--infodir=${EPREFIX}${DATAPATH}/info \
		--mandir=${EPREFIX}${DATAPATH}/man \
		--bindir=${EPREFIX}${BINPATH} \
		--libdir=${EPREFIX}${LIBPATH} \
		--libexecdir=${EPREFIX}${LIBPATH} \
		--includedir=${EPREFIX}${INCPATH} \
		--enable-64-bit-bfd \
		--enable-shared \
		--disable-werror \
		${myconf} ${EXTRA_ECONF}"
	echo ./configure ${myconf}
	"${S}"/configure ${myconf} || die "configure failed"

	emake all || die "emake failed"

	# only build info pages if we user wants them, and if
	# we have makeinfo (may not exist when we bootstrap)
	if ! has noinfo ${FEATURES} ; then
		if type -p makeinfo > /dev/null ; then
			make info || die "make info failed"
		fi
	fi
	# we nuke the manpages when we're left with junk
	# (like when we bootstrap, no perl -> no manpages)
	find . -name '*.1' -a -size 0 | xargs rm -f

	# elf2flt only works on some arches / targets
	if [[ -n ${ELF2FLT_VER} ]] && [[ ${CTARGET} == *linux* || ${CTARGET} == *-elf* ]] ; then
		cd "${WORKDIR}"/elf2flt-${ELF2FLT_VER}

		local x supported_arches=$(sed -n '/defined(TARGET_/{s:^.*TARGET_::;s:)::;p}' elf2flt.c | sort -u)
		for x in ${supported_arches} UNSUPPORTED ; do
			[[ ${CTARGET} == ${x}* ]] && break
		done

		if [[ ${x} != "UNSUPPORTED" ]] ; then
			append-flags -I"${S}"/include
			myconf="--with-bfd-include-dir=${MY_BUILDDIR}/bfd \
				--with-libbfd=${MY_BUILDDIR}/bfd/libbfd.a \
				--with-libiberty=${MY_BUILDDIR}/libiberty/libiberty.a \
				--with-binutils-ldscript-dir=${EPREFIX}/${LIBPATH}/ldscripts \
				${myconf}"
			echo ./configure ${myconf}
			./configure ${myconf} || die "configure elf2flt failed"
			emake || die "make elf2flt failed"
		fi
	fi
}

toolchain-binutils_src_test() {
	cd "${MY_BUILDDIR}"
	make check || die "check failed :("
}

toolchain-binutils_src_install() {
	local x d

	cd "${MY_BUILDDIR}"
	make DESTDIR="${D}" tooldir="${EPREFIX}/${LIBPATH}" install || die
	rm -rf "${ED}"/${LIBPATH}/bin

	# Now we collect everything intp the proper SLOT-ed dirs
	# When something is built to cross-compile, it installs into
	# /usr/$CHOST/ by default ... we have to 'fix' that :)
	if is_cross ; then
		cd "${ED}"/${BINPATH}
		for x in * ; do
			mv ${x} ${x/${CTARGET}-}
		done

		if [[ -d ${ED}/usr/${CHOST}/${CTARGET} ]] ; then
			mv "${ED}"/usr/${CHOST}/${CTARGET}/include "${ED}"/${INCPATH}
			mv "${ED}"/usr/${CHOST}/${CTARGET}/lib/* "${ED}"/${LIBPATH}/
			rm -r "${ED}"/usr/${CHOST}/{include,lib}
		fi
	fi
	insinto ${INCPATH}
	doins "${S}/include/libiberty.h"
	if [[ -d ${ED}/${LIBPATH}/lib ]] ; then
		mv "${ED}"/${LIBPATH}/lib/* "${ED}"/${LIBPATH}/
		rm -r "${ED}"/${LIBPATH}/lib
	fi
	prepman ${DATAPATH}

	# Insert elf2flt where appropriate
	if [[ -x ${WORKDIR}/elf2flt-${ELF2FLT_VER}/elf2flt ]] ; then
		cd "${WORKDIR}"/elf2flt-${ELF2FLT_VER}
		insinto ${LIBPATH}/ldscripts
		doins elf2flt.ld || die "doins elf2flt.ld failed"
		exeinto ${BINPATH}
		doexe elf2flt flthdr || die "doexe elf2flt flthdr failed"
		mv "${ED}"/${BINPATH}/{ld,ld.real} || die
		newexe ld-elf2flt ld || die "doexe ld-elf2flt failed"
		newdoc README README.elf2flt
	fi

	# Now, some binutils are tricky and actually provide
	# for multiple TARGETS.  Really, we're talking just
	# 32bit/64bit support (like mips/ppc/sparc).  Here
	# we want to tell binutils-config that it's cool if
	# it generates multiple sets of binutil symlinks.
	# e.g. sparc gets {sparc,sparc64}-unknown-linux-gnu
	local targ=${CTARGET/-*} src="" dst=""
	local FAKE_TARGETS=${CTARGET}
	case ${targ} in
		mips*)    src="mips"    dst="mips64";;
		powerpc*) src="powerpc" dst="powerpc64";;
		s390*)    src="s390"    dst="s390x";;
		sparc*)   src="sparc"   dst="sparc64";;
	esac
	case ${targ} in
		mips64*|powerpc64*|s390x*|sparc64*) targ=${src} src=${dst} dst=${targ};;
	esac
	[[ -n ${src}${dst} ]] && FAKE_TARGETS="${FAKE_TARGETS} ${CTARGET/${src}/${dst}}"

	# Generate an env.d entry for this binutils
	cd "${S}"
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
		TARGET="${CTARGET}"
		VER="${BVER}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${FAKE_TARGETS}"
	EOF
	newins env.d ${CTARGET}-${BVER}

	# Handle documentation
	if ! is_cross ; then
		cd "${S}"
		dodoc README
		docinto bfd
		dodoc bfd/ChangeLog* bfd/README bfd/PORTING bfd/TODO
		docinto binutils
		dodoc binutils/ChangeLog binutils/NEWS binutils/README
		docinto gas
		dodoc gas/ChangeLog* gas/CONTRIBUTORS gas/NEWS gas/README*
		docinto gprof
		dodoc gprof/ChangeLog* gprof/TEST gprof/TODO gprof/bbconv.pl
		docinto ld
		dodoc ld/ChangeLog* ld/README ld/NEWS ld/TODO
		docinto libiberty
		dodoc libiberty/ChangeLog* libiberty/README
		docinto opcodes
		dodoc opcodes/ChangeLog*
	fi
	# Punt all the fun stuff if user doesn't want it :)
	has noinfo ${FEATURES} && rm -r "${ED}"/${DATAPATH}/info
	has noman ${FEATURES} && rm -r "${ED}"/${DATAPATH}/man
	# Remove shared info pages
	rm -f "${ED}"/${DATAPATH}/info/{dir,configure.info,standards.info}
	# Trim all empty dirs
	find "${ED}" -type d | xargs rmdir >& /dev/null
}

toolchain-binutils_pkg_postinst() {
	# Make sure this ${CTARGET} has a binutils version selected
	[[ -e ${EROOT}/etc/env.d/binutils/config-${CTARGET} ]] && return 0
	binutils-config ${CTARGET}-${BVER}
}

toolchain-binutils_pkg_postrm() {
	local current_profile=$(binutils-config -c ${CTARGET})

	# If no other versions exist, then uninstall for this
	# target ... otherwise, switch to the newest version
	# Note: only do this if this version is unmerged.  We
	#       rerun binutils-config if this is a remerge, as
	#       we want the mtimes on the symlinks updated (if
	#       it is the same as the current selected profile)
	if [[ ! -e ${BINPATH}/ld ]] && [[ ${current_profile} == ${CTARGET}-${BVER} ]] ; then
		local choice=$(binutils-config -l | grep ${CTARGET} | awk '{print $2}')
		choice=${choice//$'\n'/ }
		choice=${choice/* }
		if [[ -z ${choice} ]] ; then
			env -i binutils-config -u ${CTARGET}
		else
			binutils-config ${choice}
		fi
	elif [[ $(CHOST=${CTARGET} binutils-config -c) == ${CTARGET}-${BVER} ]] ; then
		binutils-config ${CTARGET}-${BVER}
	fi
}
