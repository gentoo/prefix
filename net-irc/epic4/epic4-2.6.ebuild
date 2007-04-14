# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/epic4/epic4-2.6.ebuild,v 1.7 2007/04/09 05:22:07 welp Exp $

EAPI="prefix"

inherit flag-o-matic eutils

HELP_V="20050315"

DESCRIPTION="Epic4 IRC Client"
HOMEPAGE="http://epicsol.org/"
SRC_URI="ftp://ftp.epicsol.org/pub/epic/EPIC4-PRODUCTION/${P}.tar.bz2
	ftp://prbh.org/pub/epic/EPIC4-PRODUCTION/epic4-help-${HELP_V}.tar.gz
	mirror://gentoo/epic4-local.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="ipv6 perl ssl"

DEPEND=">=sys-libs/ncurses-5.2
	perl? ( >=dev-lang/perl-5.6.1 )
	ssl? ( >=dev-libs/openssl-0.9.5 )"

pkg_setup() {
	if use perl && built_with_use dev-lang/perl ithreads
	then
		error "You need perl compiled with USE=\"-ithreads\" to be able to compile epic4."
		die "perl with USE=\"-ithreads\" needed"
	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/epic-defaultserver.patch

	rm -f ${WORKDIR}/help/Makefile
	find ${WORKDIR}/help -type d -name CVS -print0 | xargs -0 rm -r
}

src_compile() {
	replace-flags "-O?" "-O"

	econf \
		--libexecdir="${EPREFIX}"/usr/lib/misc \
		$(use_with ipv6) \
		$(use_with perl) \
		$(use_with ssl) \
		|| die "econf failed"
	emake || die "make failed"
}

src_install () {
	einstall \
		sharedir=${ED}/usr/share \
		libexecdir=${ED}/usr/lib/misc || die "einstall failed"

	dodoc BUG_FORM COPYRIGHT README KNOWNBUGS VOTES

	cd ${S}/doc
	docinto doc
	dodoc \
		*.txt colors EPIC* IRCII_VERSIONS local_vars missing new-load \
		nicknames outputhelp SILLINESS TS4

	insinto /usr/share/epic/help
	doins -r ${WORKDIR}/help/* || die "doins failed"
}

pkg_postinst() {
	if [ ! -f ${EROOT}/usr/share/epic/script/local ]
	then
		einfo "/usr/share/epic/script/local does not exist, I will now"
		einfo "create it. If you do not like the look/feel of this file, or"
		einfo "if you'd prefer to use your own script, simply remove this"
		einfo "file.  If you want to prevent this file from being installed"
		einfo "in the future, simply create an empty file with this name."
		cp ${WORKDIR}/epic4-local ${EROOT}/usr/share/epic/script/local
		echo
		einfo "This provided local startup script adds a number of nifty"
		einfo "features to Epic including tab completion, a comprehensive set"
		einfo "of aliases, and channel-by-channel logging.  To prevent"
		einfo "unintentional conflicts with your own scripting, if either the"
		einfo "~/.ircrc or ~/.epicrc script files exist, then the local script"
		einfo "is *not* run.  If you like the script but want to make careful"
		einfo "additions (such as selecting your usual servers or setting your"
		einfo "nickname), simply copy /usr/share/epic/script/local to ~/.ircrc"
		einfo "and then add your additions to the copy."
	fi

	# Fix for bug 59075
	chmod 755 ${EROOT}/usr/share/epic/help
}
