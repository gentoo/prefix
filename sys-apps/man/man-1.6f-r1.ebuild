# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man/man-1.6f-r1.ebuild,v 1.10 2008/05/04 10:51:58 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Standard commands to read man pages"
HOMEPAGE="http://primates.ximian.com/~flucifredi/man/"
SRC_URI="http://primates.ximian.com/~flucifredi/man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=">=sys-apps/groff-1.19.2-r1
	!sys-apps/man-db
	!app-arch/lzma"
PROVIDE="virtual/man"

pkg_setup() {
	enewgroup man 15
	enewuser man 13 -1 ${EPREFIX}/usr/share/man man
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/man-1.6f-man2html-compression.patch
	epatch "${FILESDIR}"/man-1.6-cross-compile.patch
	epatch "${FILESDIR}"/man-1.5p-search-order.patch
	epatch "${FILESDIR}"/man-1.6f-unicode.patch #146315
	epatch "${FILESDIR}"/man-1.5p-defmanpath-symlinks.patch
	epatch "${FILESDIR}"/man-1.6b-more-sections.patch
	epatch "${FILESDIR}"/man-1.6c-cut-duplicate-manpaths.patch
	epatch "${FILESDIR}"/man-1.5m2-apropos.patch
	epatch "${FILESDIR}"/man-1.6d-fbsd.patch
	epatch "${FILESDIR}"/man-1.6e-headers.patch

	# This patch could be easily merged with the FreeBSD one, but we don't
	# because the files have no CVS header and then auto syncing overwrites the
	# local difference we make.  <grobian@gentoo.org>
	epatch "${FILESDIR}"/man-1.6e-bsdish.patch

	# Solaris needs fcntl.h included for O_CREAT etc, like SYSV
	epatch "${FILESDIR}"/man-1.6e-solaris.patch

	# hpux does not have setenv()
	epatch "${FILESDIR}"/man-1.6e-hpux.patch

	# Results in grabbing as much tools from the prefix, instead of main
	# system in a prefixed environment
	epatch "${FILESDIR}"/man-1.6e-prefix-path.patch

	# Fix the makewhatis script for prefix.
	cp "${FILESDIR}"/makewhatis.cron "${T}"/
	pushd "${T}" > /dev/null
	epatch "${FILESDIR}"/makewhatis.cron-prefix.patch
	popd > /dev/null
	eprefixify "${T}"/makewhatis.cron

	# Hardcode path to echo(1), to keep some shells (e.g. zsh, mksh) from
	# expanding "\n".
	epatch "${FILESDIR}"/man-1.6f-echo.patch
	eprefixify "${S}"/src/man.c

	strip-linguas $(eval $(grep ^LANGUAGES= configure) ; echo ${LANGUAGES//,/ })

	if use prefix ; then
		ebegin "Allowing unpriviliged install"
		sed -i \
			-e 's/@man_install_flags@//g' \
			"${S}"/src/Makefile.in
		eend $?
	fi
}

src_compile() {
	unset NLSPATH #175258

	tc-export CC BUILD_CC

	local mylang=
	if use nls ; then
		if [[ -z ${LINGUAS} ]] ; then
			mylang="all"
		else
			mylang="${LINGUAS// /,}"
		fi
	else
		mylang="none"
	fi

	local myconf=
	use prefix || myconf="${myconf} +sgid"

	[[ ${CHOST} == *-interix* ]] && append-flags "-D_POSIX_SOURCE"

	./configure \
		-prefix="${EPREFIX}/usr" \
		-confdir="${EPREFIX}"/etc \
		${myconf} \
		+fhs \
		+lang ${mylang} \
		|| die "configure failed"

	emake || die "emake failed"
}

src_install() {
	unset NLSPATH #175258

	emake DESTDIR="${D}" install || die "make install failed"
	dosym man /usr/bin/manpath

	dodoc LSM README* TODO

	# Make all Solaris man-pages available
	if [[ ${CHOST} == *-solaris* && -e /usr/share/man/man.cf ]] ; then
		source /usr/share/man/man.cf
		sed -i -e 's/^\(MANSECT.*\)$/\1:'"${MANSECTS//,/:}"'/' \
			"${ED}"/etc/man.conf || die "failed to adapt to Solaris"
	fi

	# makewhatis only adds man-pages from the last 24hrs
	exeinto /etc/cron.daily
	newexe "${T}"/makewhatis.cron makewhatis

	keepdir /var/cache/man
	use prefix || diropts -m0775 -g man && diropts -m0775
	local mansects=$(grep ^MANSECT "${ED}"/etc/man.conf | cut -f2-)
	for x in ${mansects//:/ } ; do
		keepdir /var/cache/man/cat${x}
	done
}

pkg_postinst() {
	if use !prefix ; then
		einfo "Forcing sane permissions onto ${EROOT}/var/cache/man (Bug #40322)"
		chown -R root:man "${EROOT}"/var/cache/man
		[[ -e ${EROOT}/var/cache/man/whatis ]] \
			&& chown root:0 "${EROOT}"/var/cache/man/whatis
	fi

	chmod -R g+w "${EROOT}"/var/cache/man

	echo

	local f files=$(ls "${EROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} 2>/dev/null)
	for f in ${files} ; do
		[[ ${f} == */etc/cron.daily/makewhatis ]] && continue
		[[ $(md5sum "${f}") == "8b2016cc778ed4e2570b912c0f420266 "* ]] \
			&& rm -f "${f}"
	done
	files=$(ls "${EROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} 2>/dev/null)
	if [[ ${files/$'\n'} != ${files} ]] ; then
		ewarn "You have multiple makewhatis cron files installed."
		ewarn "You might want to delete all but one of these:"
		ewarn ${files}
	fi
}
