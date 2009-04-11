# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Authen-SASL/Authen-SASL-2.12.ebuild,v 1.6 2008/11/09 11:37:09 vapier Exp $

MODULE_AUTHOR="GBARR"
inherit perl-module

DESCRIPTION="A Perl SASL interface"
HOMEPAGE="http://search.cpan.org/~gbarr/"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos ~sparc64-solaris ~x64-solaris"
IUSE="kerberos"
SRC_TEST="do"

export OPTIMIZE="$CFLAGS"
DEPEND="dev-lang/perl
		dev-perl/Digest-HMAC
		kerberos? ( dev-perl/GSSAPI )"
