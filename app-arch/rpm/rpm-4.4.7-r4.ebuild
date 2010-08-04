# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rpm/rpm-4.4.7-r4.ebuild,v 1.6 2010/06/22 19:59:58 arfrever Exp $

inherit eutils autotools distutils perl-module flag-o-matic

DESCRIPTION="Red Hat Package Management Utils"
HOMEPAGE="http://www.rpm5.org/"
SRC_URI="http://rpm5.org/files/rpm/rpm-4.4/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls python perl doc sqlite"

RDEPEND="=sys-libs/db-3.2*
	>=sys-libs/zlib-1.2.3-r1
	>=app-arch/bzip2-1.0.1
	>=dev-libs/popt-1.7
	>=app-crypt/gnupg-1.2
	dev-libs/elfutils
	virtual/libintl
	>=dev-libs/beecrypt-3.1.0-r1
	python? ( >=dev-lang/python-2.2 )
	perl? ( >=dev-lang/perl-5.8.8 )
	nls? ( virtual/libintl )
	sqlite? ( >=dev-db/sqlite-3.3.5 )
	>=net-libs/neon-0.28"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/rpm-4.4.6-with-sqlite.patch
	epatch "${FILESDIR}"/rpm-4.4.7-stupidness.patch
	epatch "${FILESDIR}"/rpm-4.4.6-autotools.patch
	epatch "${FILESDIR}"/rpm-4.4.6-buffer-overflow.patch
	epatch "${FILESDIR}"/${P}-qa-implicit-function-to-pointer.patch
	epatch "${FILESDIR}"/${P}-qa-fix-undefined.patch
	# bug 214799
	epatch "${FILESDIR}"/${PN}-4.4.6-neon-0.28.patch

	# rpm uses AM_GNU_GETTEXT() but fails to actually
	# include any of the required gettext files
	cp /usr/share/gettext/config.rpath . || die

	# the following are additional libraries that might be packaged with
	# the rpm sources. grep for "test -d" in configure.ac
	cp file/src/{file,patchlevel}.h tools/
	rm -rf beecrypt elfutils neon popt sqlite zlib intl file

	sed -i -e "s:intl ::" Makefile.am
	sed -i -e "s:intl/Makefile ::" configure.ac
	AT_NO_RECURSIVE="yes" eautoreconf
	# TODO Get rid of internal copies of lua, db and db3
}

src_compile() {
	# Until strict aliasing is porperly fixed...
	filter-flags -fstrict-aliasing
	append-flags -fno-strict-aliasing
	econf \
		--enable-posixmutexes \
		--without-javaglue \
		--without-selinux \
		$(use_with python python $(python_get_version)) \
		$(use_with doc apidocs) \
		$(use_with perl) \
		$(use_with sqlite) \
		$(use_enable nls) \
		|| die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" INSTALLDIRS=vendor install || die "emake install failed"

	mv "${ED}"/bin/rpm "${ED}"/usr/bin
	rmdir "${ED}"/bin

	use nls || rm -rf "${ED}"/usr/share/man/??

	keepdir /usr/src/rpm/{SRPMS,SPECS,SOURCES,RPMS,BUILD}

	dodoc CHANGES CREDITS GROUPS README* RPM*
	use doc && dohtml -r apidocs/html/*

	# Fix perllocal.pod file collision
	use perl && fixlocalpod
}

pkg_postinst() {
	if [[ -f "${EROOT}"/var/lib/rpm/Packages ]] ; then
		einfo "RPM database found... Rebuilding database (may take a while)..."
		"${EROOT}"/usr/bin/rpm --rebuilddb --root="${ROOT}"
	else
		einfo "No RPM database found... Creating database..."
		"${EROOT}"/usr/bin/rpm --initdb --root="${ROOT}"
	fi

	distutils_pkg_postinst
}
