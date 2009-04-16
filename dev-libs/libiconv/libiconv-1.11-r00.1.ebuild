# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.11.ebuild,v 1.9 2008/12/07 06:01:23 vapier Exp $

inherit eutils multilib flag-o-matic toolchain-funcs autotools

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
HOMEPAGE="http://www.gnu.org/software/libiconv/"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This patch is needed as libiconv 1.10 provides (and uses) new functions
	# and they are not present in the old libiconv.so, and this breaks the
	# ${DESTDIR} != ${prefix} that we use. It's a problem for Solaris, but we
	# don't have to deal with it for now.
	epatch "${FILESDIR}/${PN}-1.10-link.patch"

	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD. elibtoolize would be sufficient here, but
	# we explicitly want the installed libtool, since thats the only one thats
	# capable of everything we need, especially shared libs on interix.
	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 m4/libtool.m4
	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 libcharset/m4/libtool.m4

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	# Filter -static as it breaks compilation
	filter-ldflags -static

	# In Prefix we want to have the same header declaration on every
	# platform, so make configure find that it should do
	# "const char * *inbuf"
	export am_cv_func_iconv=no

	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext

	econf \
		--disable-nls \
		--enable-shared \
		--enable-static \
		 || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"

	# Move static libs and creates ldscripts into /usr/lib
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/lib{charset,iconv}*$(get_libname)* "${ED}/$(get_libdir)" #210239
	gen_usr_ldscript libiconv$(get_libname)
	gen_usr_ldscript libcharset$(get_libname)

	keep_aix_runtime_objects /usr/lib/libiconv.a "/usr/lib/libiconv.a(shr4.o)"
}

# keep_aix_runtime_objects() moved here from toolchain-funcs.eclass, because
# there is no other package yet that needs this, and even libiconv-1.12 does not
# need it any more.

# @FUNCTION: keep_aix_runtime_objects
# @USAGE: <target-archive inside EPREFIX> <source-archive(objects)>
# @DESCRIPTION:
# This function is for AIX only.
#
# Showing a sample IMO is the best description:
#
# First, AIX has its own /usr/lib/libiconv.a containing 'shr.o' and
# 'shr4.o'.  Both of them are shared-objects packed into an archive,
# thus /usr/lib/libiconv.a is a shared library (!), even it is called
# lib*.a.  This is the default layout on AIX for shared libraries.  Read
# the AIX ld(1) manpage for more information.
#
# But now, we want to install GNU libiconv (sys-libs/libiconv) both as
# shared and static library.  AIX (since 4.3) can create shared
# libraries if '-brtl' or '-G' linker flags are used.
#
# Now assume we have GNU tar installed while GNU libiconv was not.  This
# tar now has a runtime dependency on "libiconv.a(shr4.o)".  With our
# ld-wrapper (from sys-devel/binutils-config) we add EPREFIX/usr/lib as
# linker path, thus it is recorded as loader path into the binary.
#
# When having libiconv.a (the static GNU libiconv) in Prefix, the loader
# finds that one and claims that it does not contain an 'shr4.o' object
# file:
#
#   Could not load program tar:
#     Dependent module EPREFIX/usr/lib/libiconv.a(shr4.o) could not be loaded.
#     Member shr4.o is not found in archive
#
# According to gcc's "host/target specific installation notes" for
# *-ibm-aix* [1], we can extract that 'shr4.o' from /usr/lib/libiconv.a,
# mark it as non-linkable, and include it in our new static library.
#
# [1] http://gcc.gnu.org/install/specific.html#x-ibm-aix
#
# example:
# keep_aix_runtime_object "/usr/lib/libiconv.a "/usr/lib/libiconv.a(shr4.o,...)"
keep_aix_runtime_objects() {
	local target sources s
	local sourcelib sourceobjs so

	[[ ${CHOST} == *-*-aix* ]] || return 0

	target=$1
	shift
	sources=( "$@" )

	# strip possible ${D%/}${EPREFIX}/ prefixes
	target=${target##/}
	target=${target#${D##/}}
	target=${target#${EPREFIX##/}}
	target=${target##/}

	if ! $(tc-getAR) -t "${D%/}${EPREFIX}/${target}" &>/dev/null ; then
		if [[ -e ${D%/}${EPREFIX}/${target} ]] ; then
			ewarn "${target} is not an archive."
		fi
		return 0
	fi

	pushd $(emktemp -d) > /dev/null
	for s in "${sources[@]}" ; do
		# format of $s: "/usr/lib/libiconv.a(shr4.o,shr.o)"
		sourcelib=${s%%(*}
		sourceobjs=${s#*(}
		sourceobjs=${sourceobjs%)}
		sourceobjs=${sourceobjs//,/ }
		for so in ${sourceobjs} ; do
			ebegin "keeping aix runtime object '${sourcelib}(${so})' in '${EPREFIX}/${target}'"
			if ! $(tc-getAR) -x "${sourcelib}" ${so} ; then
				eend 1
			   	continue
			fi
			chmod +w ${so} && \
				$(tc-getSTRIP) -e ${so} && \
				$(tc-getAR) -q "${D%/}${EPREFIX}/${target}" ${so} && \
				eend 0 || \
				eend 1
		done
	done
	popd > /dev/null
}
