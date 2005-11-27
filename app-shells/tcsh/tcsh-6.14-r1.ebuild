# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/tcsh/tcsh-6.14-r1.ebuild,v 1.4 2005/11/02 22:15:37 grobian Exp $

EAPI="prefix"

# porting note:
# installation was done with double prefix, solved with einstall and
# overriding bindir and libdir.
# tcsh needs, like other shells some special treatment with regard to
# the prefixed install it is in, since it has to fetch its configuration
# files (/etc/csh.*) from the prefix as well.  This is now being catered
# for in the ebuild.

inherit eutils

MY_P="${P}.00"
DESCRIPTION="Enhanced version of the Berkeley C shell (csh)"
HOMEPAGE="http://www.tcsh.org/"
SRC_URI="ftp://ftp.astron.com/pub/tcsh/${MY_P}.tar.gz
	mirror://gentoo/${P}-conffiles.tar.bz2"
# note: starting from this version the various files scattered around
#       the place in ${FILESDIR} are now stored in a versioned tarball

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~sparc ~x86"
IUSE="perl"

DEPEND="virtual/libc
	>=sys-libs/ncurses-5.1
	perl? ( dev-lang/perl )"

S="${WORKDIR}/${MY_P}"


src_unpack() {
	unpack ${A}
	# the following patch makes tcsh prefix aware for it's config files
	epatch "${FILESDIR}/${P}"-prefix.patch
}

src_compile() {
	econf \
		$(with_bindir) \
		--libdir=${PREFIX}/usr/$(get_libdir) \
		|| die "econf failed"
	emake || die "compile problem"
}

src_install() {
	einstall \
		bindir=${D}/bin \
		libdir=${D}/usr/$(get_libdir) \
		install.man \
		|| die "make install failed"

	if use perl ; then
		perl tcsh.man2html || die
		dohtml tcsh.html/*.html
	fi

	dodoc FAQ Fixes NewThings Ported README WishList Y2K

	insinto /etc
	doins \
		"${WORKDIR}"/gentoo/csh.cshrc \
		"${WORKDIR}"/gentoo/csh.login

	insinto /etc/skel
	newins "${WORKDIR}"/gentoo/tcsh.config .tcsh.config

	insinto /etc/profile.d
	doins \
		"${WORKDIR}"/gentoo/tcsh-bindkey.csh \
		"${WORKDIR}"/gentoo/tcsh-settings.csh \
		"${WORKDIR}"/gentoo/tcsh-aliases \
		"${WORKDIR}"/gentoo/tcsh-complete \
		"${WORKDIR}"/gentoo/tcsh-gentoo_legacy
}

pkg_postinst() {
	# add csh -> tcsh symlink only if csh is not yet there
	[ ! -e /bin/csh ] && dosym /bin/tcsh /bin/csh

	while read line; do einfo "${line}"; done <<EOF
The default behaviour of tcsh has significantly changed starting from
this ebuild.  In contrast to previous ebuilds, the amount of
customisation to the default shell's behaviour has been reduced to a
bare minimum (a customised prompt).
If you rely on the customisations provided by previous ebuilds, you will
have to copy over the relevant (now commented out) parts to your own
~/.tcshrc.  Please check all tcsh-* files in /etc/profiles.d/ and add
sourceing of /etc/profiles.d/tcsh-complete to restore previous
behaviour.
Please note that the tcsh-complete file is a large set of examples that
is not meant to be used in its exact form, as it defines an excessive --
sometimes conflicting -- amount of completion scripts.  It is highly
encouraged to copy over the desired auto completion scripts to the
personal ~/.tcshrc file.  The tcsh-complete file is not any longer
sourced by the default system scripts.
EOF
}
