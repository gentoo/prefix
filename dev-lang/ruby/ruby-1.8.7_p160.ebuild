# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ruby/ruby-1.8.7_p160.ebuild,v 1.2 2009/05/10 18:52:51 a3li Exp $

#PATCHES APPLY, DOESN'T COMPILE THOUGH
#ONIGURUMA="onigd2_5_9"

inherit autotools eutils flag-o-matic multilib versionator

SLOT=$(get_version_component_range 1-2)
MY_SUFFIX=$(delete_version_separator 1 ${SLOT})

MY_P="${PN}-$(replace_version_separator 3 '-')"
S=${WORKDIR}/${MY_P}

DESCRIPTION="An object-oriented scripting language"
HOMEPAGE="http://www.ruby-lang.org/"
SRC_URI="mirror://ruby/${SLOT}/${MY_P}.tar.bz2"
#	cjk? ( http://www.geocities.jp/kosako3/oniguruma/archive/${ONIGURUMA}.tar.gz )"

LICENSE="|| ( Ruby GPL-2 )"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="berkdb debug doc emacs examples gdbm ipv6 rubytests socks5 ssl threads tk xemacs" #cjk

RDEPEND="
	berkdb? ( sys-libs/db )
	gdbm? ( sys-libs/gdbm )
	ssl? ( dev-libs/openssl )
	socks5? ( >=net-proxy/dante-1.1.13 )
	tk? ( dev-lang/tk )
	app-admin/eselect-ruby
	!=dev-lang/ruby-cvs-${SLOT}*
	!dev-ruby/rdoc
	!dev-ruby/rexml"
DEPEND="${RDEPEND}"
PDEPEND="emacs? ( app-emacs/ruby-mode )
	xemacs? ( app-xemacs/ruby-modes )"

PROVIDE="virtual/ruby"

pkg_setup() {
	use tk || return

	if (use threads && ! built_with_use dev-lang/tk threads) \
		|| (! use threads && built_with_use dev-lang/tk threads) ; then
		eerror
		eerror "You have Tk support enabled."
		eerror
		eerror "Ruby and Tk need the same 'threads' USE flag settings."
		eerror "Either change the USE flag on dev-lang/ruby or on dev-lang/tk"
		eerror "and recompile tk."

		die "threads USE flag mismatch"
	fi
}

src_unpack() {
	unpack ${A}

#	if use cjk ; then
#		einfo "Applying ${ONIGURUMA}"
#		pushd "${WORKDIR}/oniguruma"
#		econf --with-rubydir="${S}" || die "oniguruma econf failed"
#		emake $MY_SUFFIX || die "oniguruma emake failed"
#		popd
#	fi

	cd "${S}/ext/dl"
	epatch "${FILESDIR}/${PN}-1.8.6-memory-leak.diff"
	cd "${S}"
	epatch "${FILESDIR}/${PN}-mkconfig.patch"
	epatch "${FILESDIR}/${PN}${MY_SUFFIX}-mkmf-parallel-install.patch"

	epatch "${FILESDIR}/${PN}-1.8.6_p36-only-ncurses.patch"
	epatch "${FILESDIR}/${PN}-1.8.6_p36-prefix.patch"
	epatch "${FILESDIR}"/${P}-solaris.patch

	# Fix a hardcoded lib path in configure script
	sed -i -e "s:\(RUBY_LIB_PREFIX=\"\${prefix}/\)lib:\1$(get_libdir):" \
		configure.in || die "sed failed"
	
	# Fix hardcoded SHELL var in mkmf library
	sed -e "s#\(SHELL = \).*#\1${EPREFIX}/bin/sh#" -i lib/mkmf.rb

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

	econf --program-suffix=$MY_SUFFIX --enable-shared \
		$(use_enable socks5 socks) \
		$(use_enable doc install-doc) \
		$(use_enable threads pthread) \
		$(use_enable ipv6) \
		$(use_enable debug) \
		$(use_with berkdb dbm) \
		$(use_with gdbm) \
		$(use_with ssl openssl) \
		$(use_with tk) \
		${myconf} \
		--with-sitedir="${EPREFIX}"/usr/$(get_libdir)/ruby/site_ruby \
		--with-readline-dir="${EPREFIX}"/usr \
		--enable-option-checking=no \
		|| die "econf failed"

	emake EXTLDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_test() {
	emake -j1 test || die "make test failed"

	elog "Ruby's make test has been run. Ruby also ships with a make check"
	elog "that cannot be run until after ruby has been installed."
	elog
	if use rubytests; then
		elog "You have enabled rubytests, so they will be installed to"
		elog "/usr/share/${PN}-${SLOT}/test. To run them you must be a user other"
		elog "than root, and you must place them into a writeable directory."
		elog "Then call: "
		elog
		elog "ruby -C /location/of/tests runner.rb"
	else
		elog "Enable the rubytests USE flag to install the make check tests"
	fi
}

src_install() {
	# Ruby is involved in the install process, we don't want interference here.
	unset RUBYOPT

	LD_LIBRARY_PATH="${ED}/usr/$(get_libdir)"
	RUBYLIB="${S}:${LD_LIBRARY_PATH}/ruby/${SLOT}"
	for d in $(find "${S}/ext" -type d) ; do
		RUBYLIB="${RUBYLIB}:$d"
	done
	export LD_LIBRARY_PATH RUBYLIB

	emake DESTDIR="${D}" install || die "make install failed"

	MINIRUBY=$(echo -e 'include Makefile\ngetminiruby:\n\t@echo $(MINIRUBY)'|make -f - getminiruby)
	d=$(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitelibdir']")
	keepdir ${d#${EPREFIX}}
	d=$(${MINIRUBY} -rrbconfig -e "print Config::CONFIG['sitearchdir']")
	keepdir ${d#${EPREFIX}}

	if use doc; then
		make DESTDIR="${D}" install-doc || die "make install-doc failed"
	fi

	if use examples; then
		dodir usr/share/doc/${PF}
		cp -pPR sample "${ED}/usr/share/doc/${PF}"
	fi

	dosym libruby$MY_SUFFIX$(get_libname ${PV%_*}) /usr/$(get_libdir)/libruby$(get_libname ${PV%.*})
	dosym libruby$MY_SUFFIX$(get_libname ${PV%_*}) /usr/$(get_libdir)/libruby$(get_libname ${PV%_*})

	dodoc ChangeLog NEWS README* ToDo

	if use rubytests; then
		dodir /usr/share/${PN}-${SLOT}
		cp -pPR test "${ED}/usr/share/${PN}-${SLOT}"
	fi
}

pkg_postinst() {
	if [[ ! -n $(readlink "${EROOT}"usr/bin/ruby) ]] ; then
		eselect ruby set ruby${MY_SUFFIX}
	fi

	elog
	elog "This ebuild is compatible to eselect-ruby"
	elog "To switch between available Ruby profiles, execute as root:"
	elog "\teselect ruby set ruby(18|19|...)"
	elog
}

pkg_postrm() {
	if [[ ! -n $(readlink "${EROOT}"usr/bin/ruby) ]] ; then
		eselect ruby set ruby${MY_SUFFIX}
	fi
}
