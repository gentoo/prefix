# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Authen-SASL/Authen-SASL-2.10-r1.ebuild,v 1.15 2008/11/09 11:37:09 vapier Exp $

inherit perl-module

DESCRIPTION="A Perl SASL interface"
AUTHOR="GBARR"
HOMEPAGE="http://search.cpan.org/~gbarr/"
SRC_URI="mirror://cpan/authors/id/${AUTHOR:0:1}/${AUTHOR:0:2}/${AUTHOR}/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="kerberos"
SRC_TEST="do"

export OPTIMIZE="$CFLAGS"
DEPEND="dev-lang/perl
		kerberos? ( dev-perl/GSSAPI )"
