# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/quassel/quassel-0.4.2.ebuild,v 1.1 2009/05/22 21:14:48 patrick Exp $

EAPI="2"

inherit cmake-utils eutils

DESCRIPTION="Qt4/KDE4 IRC client suppporting a remote daemon for 24/7 connectivity."
HOMEPAGE="http://quassel-irc.org/"
SRC_URI="http://quassel-irc.org/pub/${P}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
SLOT="0"
IUSE="dbus debug kde monolithic +oxygen phonon +server +ssl webkit +X"

LANGS="cs da de fr hu nb_NO ru sl tr"
for l in ${LANGS}; do
	IUSE="${IUSE} linguas_${l}"
done

RDEPEND="
	dbus? ( x11-libs/qt-dbus:4 )
	monolithic? (
		dev-db/sqlite[threadsafe]
		x11-libs/qt-sql:4[sqlite]
		x11-libs/qt-script:4
		x11-libs/qt-gui:4
		kde? ( >=kde-base/kdelibs-4.1 )
		phonon? ( || ( media-sound/phonon x11-libs/qt-phonon ) )
		webkit? ( x11-libs/qt-webkit:4 )
	)
	!monolithic? (
		server? (
			dev-db/sqlite[threadsafe]
			x11-libs/qt-sql:4[sqlite]
			x11-libs/qt-script:4
		)
		X? (
			x11-libs/qt-gui:4
			kde? ( >=kde-base/kdelibs-4.1 )
			phonon? ( || ( media-sound/phonon x11-libs/qt-phonon ) )
			webkit? ( x11-libs/qt-webkit:4 )
		)
	)
	ssl? ( x11-libs/qt-core:4[ssl] )
	"
DEPEND="${RDEPEND}"

DOCS="AUTHORS ChangeLog README"

pkg_setup() {
	if ! use monolithic && ! use server && ! use X ; then
		eerror "You have to build at least one of the monolithic client (USE=monolithic),"
		eerror "the quasselclient (USE=X) or the quasselcore (USE=server)."
		die "monolithic, server and X flag unset."
	fi
}

src_configure() {
	local MY_LANGUAGES=""
	for i in ${LINGUAS}; do
		MY_LANGUAGES="${i},${MY_LANGUAGES}"
	done

	local mycmakeargs="
		$(cmake-utils_use_want X QTCLIENT)
		$(cmake-utils_use_want server CORE)
		$(cmake-utils_use_want monolithic MONO)
		$(cmake-utils_use_with webkit WEBKIT)
		$(cmake-utils_use_with phonon PHONON)
		$(cmake-utils_use_with kde KDE)
		$(cmake-utils_use_with dbus DBUS)
		$(cmake-utils_use_with ssl OPENSSL)
		$(cmake-utils_use_with oxygen OXYGEN)
		-DEMBED_DATA=OFF
		-DLINGUAS=${MY_LANGUAGES}
		"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use server ; then
		newinitd "${FILESDIR}"/quasselcore-2.init quasselcore || die "newinitd failed"
		newconfd "${FILESDIR}"/quasselcore-2.conf quasselcore || die "newconfd failed"

		insinto /etc/logrotate.d
		newins "${FILESDIR}/quassel.logrotate" quassel

		insinto /usr/share/doc/${PF}
		doins "${S}"/scripts/manageusers.py || die "installing manageusers.py failed"
	fi
}

pkg_postinst() {
	if use server ; then
		ewarn
		ewarn "In order to use the quassel init script you must set the"
		ewarn "QUASSEL_USER variable in ${ROOT%/}/etc/conf.d/quasselcore to your username."
		ewarn "Note: This is the user who runs the quasselcore and is independent"
		ewarn "from the users you set up in the quasselclient."
		elog
		elog "Adding more than one user or changing username/password is not"
		elog "possible via the quasselclient yet. If you need to do these things"
		elog "you have to use the manageusers.py script, which has been installed in"
		elog "${ROOT%/}/usr/share/doc/${PF}".
		elog "http://bugs.quassel-irc.org/wiki/quassel-irc/Manage_core_users provides"
		elog "some information on using the script."
		elog "To be sure nothing bad will happen you need to stop the quasselcore"
		elog "before adding more users."
	fi

	if ( use server || use monolithic ) && use ssl ; then
		elog
		elog "Information on how to enable SSL support for client/core connections"
		elog "is available at http://bugs.quassel-irc.org/wiki/quassel-irc."
	fi
}
