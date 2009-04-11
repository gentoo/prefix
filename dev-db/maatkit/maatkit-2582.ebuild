# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/maatkit/maatkit-2582.ebuild,v 1.1 2009/03/07 15:15:50 patrick Exp $

inherit perl-app

IUSE=""
DESCRIPTION="maatkit: essential command-line utilities for MySQL"
HOMEPAGE="http://www.maatkit.org/"
SRC_URI="http://maatkit.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
DEPEND="dev-perl/DBD-mysql"
