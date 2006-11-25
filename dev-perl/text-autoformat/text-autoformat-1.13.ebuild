# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/text-autoformat/text-autoformat-1.13.ebuild,v 1.10 2006/10/20 20:28:23 kloeri Exp $

EAPI="prefix"

inherit perl-module

MY_P=Text-Autoformat-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Automatic text wrapping and reformatting"
SRC_URI="mirror://cpan/authors/id/D/DC/DCONWAY/${MY_P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-module/Text/${MY_P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=dev-perl/text-reform-1.11
	dev-lang/perl"
RDEPEND="${DEPEND}"

