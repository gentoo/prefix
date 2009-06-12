# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/MIME-Base64/MIME-Base64-3.08.ebuild,v 1.2 2009/06/11 10:44:04 aballier Exp $

EAPI=2

MODULE_AUTHOR=GAAS
inherit perl-module

DESCRIPTION="A base64/quoted-printable encoder/decoder Perl Modules"

SLOT="0"
KEYWORDS="~x86-solaris ~x64-solaris ~sparc-solaris ~sparc64-solaris ~x86-macos ~ppc-macos ~amd64-linux ~ia64-linux ~x86-linux ~x86-freebsd"
IUSE=""

SRC_TEST="do"
