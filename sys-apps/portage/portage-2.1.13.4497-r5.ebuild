# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils toolchain-funcs autotools

DESCRIPTION="Prefix branch of the Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/prefix-${PN}-${PV}.tar.bz2"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"

SLOT="0"
IUSE="build doc selinux"
DEPEND=">=dev-lang/python-2.3"
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

S=${WORKDIR}/prefix-${PN}-${PV/-r1/}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-double_prefix.patch
	epatch "${FILESDIR}"/${P}-prefix-qa.patch
	epatch "${FILESDIR}"/${P}-matt-various_fixes.patch
	epatch "${FILESDIR}"/${P}-matt-config_protect.patch
}

src_compile() {
	echo ${S}
	econf \
		--with-user=${PORTAGE_USER:-portage} \
		--with-group=${PORTAGE_GROUP:-portage} \
		--with-rootuser=${PORTAGE_INST_USER:-root} \
		--with-wheelgid=${PORTAGE_INST_GID:-0} \
		--with-offset-prefix=${EPREFIX} \
		|| die "econf failed"

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed."
	dodir /usr/lib/portage/bin
	dodir /etc/portage
	dodir /var/lib/portage
	dodir /var/log/portage
	keepdir /etc/portage

	ebegin "Adjusting to prefix"
	sed \
		-e "s|GENTOO_PORTAGE_EPREFIX|${EPREFIX}|g" \
		"${FILESDIR}"/05portage.envd \
		> "${T}"/05portage.envd
	eend $?
	doenvd "${T}"/05portage.envd
}

pkg_preinst() {
	if has livecvsportage ${FEATURES} && [ "${ROOT}" = "/" ]; then
		rm -rf ${D}/usr/lib/portage/pym/*
		mv ${D}/usr/lib/portage/bin/tbz2tool ${T}
		rm -rf ${D}/usr/lib/portage/bin/*
		mv ${T}/tbz2tool ${D}/usr/lib/portage/bin/
	else
		rm ${EPREFIX}/usr/lib/portage/pym/*.pyc >& /dev/null
		rm ${EPREFIX}/usr/lib/portage/pym/*.pyo >& /dev/null
	fi
}

pkg_postinst() {
	local x

	if [ ! -f "${ROOT}/var/lib/portage/world" ] &&
	   [ -f ${ROOT}/var/cache/edb/world ] &&
	   [ ! -h ${ROOT}/var/cache/edb/world ]; then
		mv ${ROOT}/var/cache/edb/world ${ROOT}/var/lib/portage/world
		ln -s ../../lib/portage/world ${EPREFIX}/var/cache/edb/world
	fi

	for x in ${ROOT}/etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${ROOT}/etc/make.globals"
	done
}
