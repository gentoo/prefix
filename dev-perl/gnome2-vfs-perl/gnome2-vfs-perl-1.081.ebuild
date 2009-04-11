# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/gnome2-vfs-perl/gnome2-vfs-perl-1.081.ebuild,v 1.1 2008/09/21 06:22:45 tove Exp $

inherit perl-module

MY_P=Gnome2-VFS-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Perl interface to the 2.x series of the Gnome Virtual File System libraries."
HOMEPAGE="http://search.cpan.org/~tsch/"
SRC_URI="mirror://cpan/authors/id/T/TS/TSCH/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=gnome-base/gnome-vfs-2
	>=dev-perl/glib-perl-1.120
	dev-lang/perl"
DEPEND="${RDEPEND}
	>=dev-perl/extutils-depends-0.2
	>=dev-perl/extutils-pkgconfig-1.03
	dev-util/pkgconfig"

SRC_TEST=do

src_test(){
	if [[ ${UID} == 0 || ${HOME} = /root ]] ; then
		ewarn "Test skipped. Don't run tests as root."
		return
	fi
	mkdir "${HOME}/.gnome"
	perl-module_src_test
}
