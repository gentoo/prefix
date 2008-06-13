# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/replytolist/replytolist-0.3.0.ebuild,v 1.1 2007/12/11 17:45:32 armin76 Exp $

EAPI="prefix"

inherit mozextension multilib

DESCRIPTION="Thunderbird extension to reply to mailing list"
HOMEPAGE="http://alumnit.ca/wiki/index.php?page=ReplyToListThunderbirdExtension"
SRC_URI="http://alumnit.ca/wiki/attachments/${P}.xpi"

KEYWORDS="~amd64-linux ~x86-linux"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

RDEPEND=">=mail-client/mozilla-thunderbird-2.0_alpha1"
DEPEND="${RDEPEND}"

#S="${WORKDIR}"

src_unpack() {
	xpi_unpack ${P}.xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/mozilla-thunderbird"

	emid=$(sed -n -e '/<\?em:id>\?/!d; s/.*\([\"{].*[}\"]\).*/\1/; s/\"//g; p;' install.rdf | sed -e '1d') || die "failed to determine extension id"
	insinto "${MOZILLA_FIVE_HOME}"/extensions/${emid}
	doins -r * || die "failed to copy extension"
}
