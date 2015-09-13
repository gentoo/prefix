# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

LIBTOOLIZE="true" #225559
WANT_LIBTOOL="none"
inherit eutils autotools multilib unpacker prefix

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.savannah.gnu.org/${PN}.git
		http://git.savannah.gnu.org/r/${PN}.git"
	inherit git-2
else
	SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"
	KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="https://www.gnu.org/software/libtool/"

LICENSE="GPL-2"
SLOT="2"
IUSE="vanilla"

# Pull in libltdl directly until we convert packages to the new dep.
RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.69
	>=sys-devel/automake-1.13
	dev-libs/libltdl:0"
DEPEND="${RDEPEND}
	app-arch/xz-utils"
[[ ${PV} == "9999" ]] && DEPEND+=" sys-apps/help2man"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git-2_src_unpack
		cd "${S}"
		./bootstrap || die
	else
		unpacker_src_unpack
	fi
}

src_prepare() {
	use vanilla && return 0

	epatch "${FILESDIR}"/2.4/${PN}-2.4.6-mint.patch
	epatch "${FILESDIR}"/2.2.6a/${PN}-2.2.6a-darwin-module-bundle.patch
	epatch "${FILESDIR}"/2.4/${PN}-2.4.6-darwin-use-linux-version.patch

	# seems that libtool has to know about EPREFIX a little bit better,
	# since it fails to find prefix paths to search libs from, resulting in
	# some packages building static only, since libtool is fooled into
	# thinking that libraries are unavailable (argh...). This could also be
	# fixed by making the gcc wrapper return the correct result for
	# -print-search-dirs (doesn't include prefix dirs ...).
	if use prefix ; then
		epatch "${FILESDIR}"/2.2.10/${PN}-2.2.10-eprefix.patch
		eprefixify m4/libtool.m4
	fi

	epatch "${FILESDIR}"/${PN}-2.4.3-use-linux-version-in-fbsd.patch #109105
	epatch "${FILESDIR}"/${P}-fuse-ld.patch
	pushd libltdl >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	popd >/dev/null
	AT_NOELIBTOOLIZE=yes eautoreconf
	epunt_cxx

	# Make sure timestamps don't trigger a rebuild of man pages. #556512
	if [[ ${PV} != "9999" ]] ; then
		touch doc/*.1
		export HELP2MAN=false
	fi
}

src_configure() {
	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL="$(type -P bash)"

	local myconf
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	ECONF_SOURCE=${S} econf ${myconf} --disable-ltdl-install
}

src_test() {
	emake check
}

src_install() {
	default

	local x
	while read -d $'\0' -r x ; do
		ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}" || die
	done < <(find "${ED}" '(' -name config.guess -o -name config.sub ')' -print0)
}
