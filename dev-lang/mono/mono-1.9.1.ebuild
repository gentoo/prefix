# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-1.9.1.ebuild,v 1.3 2008/06/18 02:52:17 compnerd Exp $

EAPI="prefix"

inherit eutils flag-o-matic multilib autotools

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"
SRC_URI="http://www.go-mono.com/sources/mono/${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 X11 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="X nptl moonlight"

RDEPEND="!<dev-dotnet/pnet-0.6.12
		 >=dev-libs/glib-2.6
		 nptl? ( >=sys-devel/gcc-3.3.5-r1 )
		 ppc?	(
					>=sys-devel/gcc-3.2.3-r4
					>=sys-libs/glibc-2.3.3_pre20040420
				)
		 X? ( >=dev-dotnet/libgdiplus-1.9 )"
DEPEND="${RDEPEND}
		  sys-devel/bc
		>=dev-util/pkgconfig-0.19"
PDEPEND="dev-dotnet/pe-format"

# Parallel build unfriendly
MAKEOPTS="${MAKEOPTS} -j1"

RESTRICT="test"

function get-memory-total() {
	cat /proc/meminfo | grep MemTotal | sed -r "s/[^0-9]*([[0-9]+).*/\1/"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the install path, install into $(libdir)
	sed -i -e 's:$(prefix)/lib:$(libdir):'                                    \
		-i -e 's:$(exec_prefix)/lib:$(libdir):'                               \
		-i -e "s:'mono_libdir=\${exec_prefix}/lib':\"mono_libdir=\$libdir\":" \
		"${S}"/{scripts,mono/metadata}/Makefile.am "${S}"/configure.in        \
	|| die "sed failed"

	sed -i -e 's:^libdir.*:libdir=@libdir@:'                                  \
		-i -e 's:${prefix}/lib/:${libdir}/:g'                                 \
		"${S}"/{scripts,}/*.pc.in                                             \
	|| die "sed failed"

	# Remove dummy ltconfig and let libtool handle it
	rm -f "${S}"/libgc/ltconfig

	epatch "${FILESDIR}/${PN}-biginteger_overflow.diff"
	epatch "${FILESDIR}/${PN}-1.9.1-glibc-2.8-deprecated-arg-max.patch"

	einfo "Regenerating the build files, this will take some time..."
	eautoreconf
}

src_compile() {
	# mono's build system is finiky, strip the flags
	strip-flags
	if [[ ${CHOST} == *-solaris* ]]; then
		# if gc=included there will be a segfault during the make procces
		# if gc=bohme the build will run in a endless loop
		local myconf="--with-preview=yes --with-glib=system --with-gc=none"
	else
		# Enable the 2.0 FX, use the system glib and the gc
		local myconf="--with-preview=yes --with-glib=system --with-gc=included"
	fi

	# Threading support
	if use amd64 || use nptl ; then
		# force __thread on amd64 (bug #83770)
		myconf="${myconf} --with-tls=__thread"
	else
		myconf="${myconf} --with-tls=pthread"
	fi

	# Enable large heaps if memory is more than >=3GB
	if [[ $(get-memory-total) -ge 3145728 ]] ; then
		myconf="${myconf} --with-large-heap=yes"
	fi

	# Force the use of monolite mcs to prevent issues with classlibs (bug #118062)
	touch "${S}"/mcs/build/deps/use-monolite

	econf ${myconf} $(use_with moonlight) || die "configure failed"
	emake EXTERNAL_MCS=false EXTERNAL_MONO=false

	if [[ "$?" -ne "0" ]]; then
		ewarn "If you are using any hardening features such as"
		ewarn "PIE+SSP/SELinux/grsec/PAX then most probably this is the reason"
		ewarn "why build has failed. In this case turn any active security"
		ewarn "enhancements off and try emerging the package again"
		die
	fi
}

src_test() {
	vecho ">>> Test phase [check]: ${CATEGORY}/${PF}"

	mkdir -p "${T}/home/mono" || die "mkdir home failed"

	export HOME="${T}/home/mono"
	export XDG_CONFIG_HOME="${T}/home/mono"
	export XDG_DATA_HOME="${T}/home/mono"

	if ! LC_ALL=C emake -j1 check; then
		hasq test $FEATURES && die "Make check failed. See above for details."
		hasq test $FEATURES || eerror "Make check failed. See above for details."
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog
}
