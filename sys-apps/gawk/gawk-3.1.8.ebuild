# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.8.ebuild,v 1.1 2010/05/20 04:11:03 vapier Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRC_URI="mirror://gnu/gawk/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SFFS=${WORKDIR}/filefuncs

src_unpack() {
	unpack ${A}

	# Copy filefuncs module's source over ...
	cp -r "${FILESDIR}"/filefuncs "${SFFS}" || die "cp failed"
}

src_prepare() {
	# use symlinks rather than hardlinks, and disable version links
	sed -i \
		-e '/^LN =/s:=.*:= $(LN_S):' \
		-e '/install-exec-hook:/s|$|\nfoo:|' \
		Makefile.in doc/Makefile.in

	# on solaris, we have stupid /usr/bin/awk, but gcc,
	# which's preprocessor understands '\'-linebreaks
# fails to apply, still necessary?
#	epatch "${FILESDIR}"/${PN}-3.1.5-stupid-awk-clever-cc.patch
	epatch "${FILESDIR}"/${PN}-3.1.6-mint.patch
	#elibtoolize # needed for FreeMiNT
}

src_configure() {
	export ac_cv_libsigsegv=no
	econf \
		--libexec='$(libdir)/misc' \
		$(use_enable nls) \
		--enable-switch
}

src_compile() {
	emake || die
	emake -C "${SFFS}" CC=$(tc-getCC) || die "filefuncs emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	emake -C "${SFFS}" LIBDIR="$(get_libdir)" install || die

	# Keep important gawk in /bin
	if use userland_GNU ; then
		dodir /bin
		mv "${ED}"/usr/bin/gawk "${ED}"/bin/ || die
		dosym /bin/gawk /usr/bin/gawk

		# Provide canonical `awk`
		dosym gawk /bin/awk
		dosym gawk /usr/bin/awk
		dosym gawk.1 /usr/share/man/man1/awk.1
	fi

	# Install headers
	insinto /usr/include/awk
	doins *.h || die
	# We do not want 'acconfig.h' in there ...
	rm -f "${ED}"/usr/include/awk/acconfig.h

	dodoc AUTHORS ChangeLog FUTURES LIMITATIONS NEWS PROBLEMS POSIX.STD README README_d/*.*
	for x in */ChangeLog ; do
		newdoc ${x} ${x##*/}.${x%%/*}
	done
}
