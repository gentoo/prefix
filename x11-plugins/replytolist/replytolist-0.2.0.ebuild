# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/replytolist/replytolist-0.2.0.ebuild,v 1.14 2007/06/15 17:26:55 armin76 Exp $

EAPI="prefix"

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to reply to mailing list"
HOMEPAGE="http://open.nit.ca/wiki/index.php?page=ReplyToListThunderbirdExtension"

KEYWORDS="~amd64 ~ia64 ~x86"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

RDEPEND=">=mail-client/mozilla-thunderbird-2.0_alpha1
		>=x11-plugins/enigmail-0.94.1-r1"
DEPEND="${RDEPEND}"

SRC_URI="http://open.nit.ca/wiki/attachments/"${P}".xpi"

S="${WORKDIR}"

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-thunderbird"

	xpi_install "${S}"/"${P}"
}
