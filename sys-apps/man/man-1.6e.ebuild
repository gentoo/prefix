# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man/man-1.6e.ebuild,v 1.1 2006/11/29 05:18:12 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Standard commands to read man pages"
HOMEPAGE="http://primates.ximian.com/~flucifredi/man/"
SRC_URI="http://primates.ximian.com/~flucifredi/man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
DEPEND=">=sys-apps/groff-1.18
	!sys-apps/man-db"
PROVIDE="virtual/man"

pkg_setup() {
	enewgroup man 15
	enewuser man 13 -1 ${EPREFIX}/usr/share/man man
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We love to cross-compile
	epatch "${FILESDIR}"/man-1.6-cross-compile.patch

	# Fix search order in man.conf so that system installed manpages
	# will be found first ...
	epatch "${FILESDIR}"/man-1.5p-search-order.patch

	# For groff-1.18 or later we need to call nroff with '-c'
	epatch "${FILESDIR}"/man-1.5m-groff-1.18.patch

	# makewhatis traverses manpages twice, as default manpath
	# contains two directories that are symlinked together
	epatch "${FILESDIR}"/man-1.5p-defmanpath-symlinks.patch

	# add more sections to default search path
	epatch "${FILESDIR}"/man-1.6b-more-sections.patch

	# cut out symlinked paths #90186
	epatch "${FILESDIR}"/man-1.6c-cut-duplicate-manpaths.patch

	# Fedora patches
	epatch "${FILESDIR}"/man-1.5m2-apropos.patch

	# Fixes compilation in FreeBSD wrt #138123
	epatch "${FILESDIR}"/man-1.6d-fbsd.patch

	# This patch could be easily merged with the FreeBSD one, but we don't
	# because the files have no CVS header and then auto syncing overwrites the
	# local difference we make.  <grobian@gentoo.org>
	epatch "${FILESDIR}"/man-1.6e-darwin.patch

	# Results in grabbing as much tools from the prefix, instead of main
	# system in a prefixed environment
	epatch "${FILESDIR}"/man-1.6d-prefix-path.patch

	# Fix the makewhatis script for prefix.
	cp "${FILESDIR}"/makewhatis.cron "${T}"/
	( cd "${T}" && epatch "${FILESDIR}"/makewhatis.cron-prefix.patch )
	eprefixify "${T}"/makewhatis.cron

	strip-linguas $(eval $(grep ^LANGUAGES= configure) ; echo ${LANGUAGES//,/ })

	ebegin "Allowing unpriviliged install"
	sed -i \
		-e 's/@man_install_flags@//g' \
		${S}/src/Makefile.in
	eend $?
}

src_compile() {
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
	[[ ${EPREFIX%/} == "" ]] && myconf="${myconf} +sgid"

	./configure \
		-confdir="${EPREFIX}"/etc \
		${myconf} \
		+fhs \
		+lang ${mylang} \
		|| die "configure failed"

	append-ldflags $(bindnow-flags)
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" PREFIX="${EPREFIX}" install || die "make install failed"
	dosym man /usr/bin/manpath

	# man setup is kind of broken, so man.conf installs in double prefix, but
	# otherwise it doesn't use prefix when looking for it, or the rest is
	# installed wrongly
	mkdir -p "${ED}"/etc/
	mv "${ED}/${EPREFIX}"/etc/man.conf "${ED}"/etc/
	PREF=${EPREFIX#/}
	rm -R "${ED}/${PREF%%/*}"

	dodoc LSM README* TODO

	exeinto /etc/cron.weekly
	newexe "${T}"/makewhatis.cron makewhatis

	keepdir /var/cache/man
	[[ ${EPREFIX%/} == "" ]] && diropts -m0775 -g man || diropts -m0775
	local mansects=$(grep ^MANSECT "${ED}"/etc/man.conf | cut -f2-)
	for x in ${mansects//:/ } ; do
		keepdir /var/cache/man/cat${x}
	done
}

pkg_postinst() {
	einfo "Forcing sane permissions onto ${EROOT}/var/cache/man (Bug #40322)"
	chown -R root:man "${EROOT}"/var/cache/man
	chmod -R g+w "${EROOT}"/var/cache/man
	[[ -e ${EROOT}/var/cache/man/whatis ]] \
		&& chown root:0 "${EROOT}"/var/cache/man/whatis

	echo

	local files=$(ls "${EROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} 2>/dev/null)
	if [[ ${files/$'\n'} != ${files} ]] ; then
		ewarn "You have multiple makewhatis cron files installed."
		ewarn "You might want to delete all but one of these:"
		ewarn ${files}
	fi
}
