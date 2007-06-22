# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"
RESTRICT="mirror"

inherit eutils toolchain-funcs autotools

DESCRIPTION="Prefix branch of the Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/prefix-${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"

SLOT="0"
IUSE="build doc selinux"
DEPEND=">=dev-lang/python-2.3
	>=sys-apps/portage-2.1.20.4758"
RDEPEND="!build? ( >=sys-apps/sed-4.0.5 \
		dev-python/python-fchksum \
		>=dev-lang/python-2.3 \
		userland_GNU? ( sys-apps/debianutils ) \
		>=app-shells/bash-2.05a ) \
		selinux? ( >=dev-python/python-selinux-2.15 ) \
		doc? ( app-portage/portage-manpages )
		>=dev-python/pycrypto-2.0.1"
#		!userland_Darwin? ( app-misc/pax-utils sys-apps/sandbox ) \

PROVIDE="virtual/portage"

S=${WORKDIR}/prefix-${PN}-${PV}

src_unpack() {
	unpack ${A}

	cp "${FILESDIR}"/05portage.envd "${T}"/05portage.envd
	eprefixify "${T}"/05portage.envd
}

src_compile() {
	econf \
		--with-user=${PORTAGE_USER:-portage} \
		--with-group=${PORTAGE_GROUP:-portage} \
		--with-rootuser=${PORTAGE_INST_USER:-root} \
		--with-wheelgid=${PORTAGE_INST_GID:-0} \
		--with-offset-prefix=${EPREFIX} \
		--with-default-path="/usr/bin:/bin" \
		|| die "econf failed"

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed."
	dodir /usr/lib/portage/bin
	dodir /etc/portage
	dodir /var/lib/portage
	dodir /var/log/portage
	keepdir /etc/portage

	doenvd "${T}"/05portage.envd
}

pkg_preinst() {
	if has livecvsportage ${FEATURES} && [ "${ROOT}" = "/" ]; then
		rm -rf ${ED}/usr/lib/portage/pym/*
		mv ${ED}/usr/lib/portage/bin/tbz2tool ${T}
		rm -rf ${ED}/usr/lib/portage/bin/*
		mv ${T}/tbz2tool ${ED}/usr/lib/portage/bin/
	else
		rm ${EPREFIX}/usr/lib/portage/pym/*.pyc >& /dev/null
		rm ${EPREFIX}/usr/lib/portage/pym/*.pyo >& /dev/null
	fi
}

pkg_postinst() {
	local x

	if [ ! -f "${EROOT}/var/lib/portage/world" ] &&
	   [ -f ${EROOT}/var/cache/edb/world ] &&
	   [ ! -h ${EROOT}/var/cache/edb/world ]; then
		mv ${EROOT}/var/cache/edb/world ${EROOT}/var/lib/portage/world
		ln -s ../../lib/portage/world ${EROOT}/var/cache/edb/world
	fi

	for x in ${EROOT}/etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${EROOT}/etc/make.globals"
	done
}
