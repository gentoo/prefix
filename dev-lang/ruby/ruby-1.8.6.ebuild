# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ruby/ruby-1.8.6.ebuild,v 1.2 2007/04/07 16:23:57 pclouds Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

# A new version is needed for 1.8.6, currently disabled.
ONIGURUMA="onigd2_5_8"

inherit flag-o-matic alternatives eutils multilib autotools versionator

DESCRIPTION="An object-oriented scripting language"
HOMEPAGE="http://www.ruby-lang.org/"
SRC_URI="ftp://ftp.ruby-lang.org/pub/ruby/$(get_version_component_range 1-2)/${P}.tar.gz"
#	cjk? ( http://www.geocities.jp/kosako3/oniguruma/archive/${ONIGURUMA}.tar.gz )"

LICENSE="Ruby"
SLOT="1.8"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="debug socks5 tk doc threads examples ipv6" # cjk
RESTRICT="confcache"

RDEPEND=">=sys-libs/gdbm-1.8.0
	>=sys-libs/readline-4.1
	>=sys-libs/ncurses-5.2
	socks5? ( >=net-proxy/dante-1.1.13 )
	tk? ( dev-lang/tk )
	>=dev-ruby/ruby-config-0.3.1
	!=dev-lang/ruby-cvs-1.8*
	!dev-ruby/rdoc
	!dev-ruby/rexml"
DEPEND="${RDEPEND}"
PROVIDE="virtual/ruby"

src_unpack() {
	unpack ${A}

#	if use cjk ; then
#		einfo "Applying ${ONIGURUMA}"
#		pushd ${WORKDIR}/oniguruma
##		epatch ${FILESDIR}/oniguruma-2.3.1-gentoo.patch
#		econf --with-rubydir=${S} || die "econf failed"
#		MY_PV=$(get_version_component_range 1-2)
#		make ${MY_PV/./}
#		popd
#	fi

	cd "${S}"

	# Fix a hardcoded lib path in configure script
	sed -i -e "s:\(RUBY_LIB_PREFIX=\"\${prefix}/\)lib:\1$(get_libdir):" \
		configure.in || die "sed failed"

	eautoreconf
}

src_compile() {
	# -fomit-frame-pointer makes ruby segfault, see bug #150413.
	filter-flags -fomit-frame-pointer
	# In many places aliasing rules are broken; play it safe
	# as it's risky with newer compilers to leave it as it is.
	append-flags -fno-strict-aliasing

	# Socks support via dante
	if use socks5 ; then
		# Socks support can't be disabled as long as SOCKS_SERVER is
		# set and socks library is present, so need to unset
		# SOCKS_SERVER in that case.
		unset SOCKS_SERVER
	fi

	# Increase GC_MALLOC_LIMIT if set (default is 8000000)
	if [ -n "${RUBY_GC_MALLOC_LIMIT}" ] ; then
		append-flags "-DGC_MALLOC_LIMIT=${RUBY_GC_MALLOC_LIMIT}"
	fi

	econf --program-suffix=${SLOT/./} --enable-shared \
		$(use_enable socks5 socks) \
		$(use_enable doc install-doc) \
		$(use_enable threads pthread) \
		$(use_enable ipv6 ipv6) \
		$(use_enable debug debug) \
		--with-sitedir="${EPREFIX}"/usr/$(get_libdir)/ruby/site_ruby \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	LD_LIBRARY_PATH="${ED}"/usr/$(get_libdir)
	RUBYLIB="${S}:${ED}/usr/$(get_libdir)/ruby/${SLOT}"
	for d in $(find ${S}/ext -type d) ; do
		RUBYLIB="${RUBYLIB}:$d"
	done
	export LD_LIBRARY_PATH RUBYLIB

	make DESTDIR="${D}" install || die "make install failed"

	MINIRUBY=$(echo -e 'include Makefile\ngetminiruby:\n\t@echo $(MINIRUBY)'|make -f - getminiruby)
	d=$(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitelibdir']")
	keepdir ${d#${EPREFIX}}
	d=$(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitearchdir']")
	keepdir ${d#${EPREFIX}}

	if use doc; then
		make DESTDIR="${D}" install-doc || die "make install-doc failed"
	fi

	if use examples; then
		dodir ${ROOT}usr/share/doc/${PF}
		cp -pPR sample ${ED}/${ROOT}usr/share/doc/${PF}
	fi

	dosym libruby${SLOT/./}$(get_libname ${PV%_*}) /usr/$(get_libdir)/libruby$(get_libname ${PV%.*})
	dosym libruby${SLOT/./}$(get_libname ${PV%_*}) /usr/$(get_libdir)/libruby$(get_libname ${PV%_*})

	dodoc ChangeLog NEWS README* ToDo
}

pkg_postinst() {
	ewarn
	ewarn "Warning: Vim won't work if you've just updated ruby from"
	ewarn "1.6.x to 1.8.x due to the library version change."
	ewarn "In that case, you will need to remerge vim."
	ewarn

	if [ ! -n "$(readlink ${EROOT}usr/bin/ruby)" ] ; then
		${EROOT}usr/sbin/ruby-config ruby${SLOT/./}
	fi
	einfo
	einfo "You can change the default ruby interpreter by ${EROOT}/usr/sbin/ruby-config"
	einfo
}

pkg_postrm() {
	if [ ! -n "$(readlink ${EROOT}/usr/bin/ruby)" ] ; then
		${EROOT}/usr/sbin/ruby-config ruby${SLOT/./}
	fi
}
