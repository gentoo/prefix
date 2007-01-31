# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/ruby-gnome2.eclass,v 1.11 2007/01/26 15:53:18 pclouds Exp $
#
# This eclass simplifies installation of the various pieces of
# ruby-gnome2 since they share a very common installation procedure.
# It's possible that this could provide a foundation for a generalized
# ruby-module.eclass, but at the moment it contains some things
# specific to ruby-gnome2

# Variables:
# PATCHES	Space delimited list of patch files.

EXPORT_FUNCTIONS src_compile src_install src_unpack

IUSE=""

subbinding=${PN#ruby-} ; subbinding=${subbinding%2}
if [[ ${PV} == 0.5.0 ]]; then
	S=${WORKDIR}/ruby-gnome2-${PV}/${subbinding}
	SRC_URI="mirror://sourceforge/ruby-gnome2/ruby-gnome2-${PV}.tar.gz"
else
	S=${WORKDIR}/ruby-gnome2-all-${PV}/${subbinding}
	SRC_URI="mirror://sourceforge/ruby-gnome2/ruby-gnome2-all-${PV}.tar.gz"
fi
HOMEPAGE="http://ruby-gnome2.sourceforge.jp/"
LICENSE="Ruby"
SLOT="0"

DEPEND="virtual/ruby"
RDEPEND="virtual/ruby"

ruby-gnome2_src_unpack() {
	if [ ! -x /bin/install -a -x /usr/bin/install ]; then
		cat <<END >${T}/mkmf.rb
require 'mkmf'

STDERR.puts 'patching mkmf'
CONFIG['INSTALL'] = '/usr/bin/install'
END
		# save it because rubygems needs it (for unsetting RUBYOPT)
		export GENTOO_RUBYOPT="-r${T}/mkmf.rb"
		export RUBYOPT="${RUBYOPT} ${GENTOO_RUBYOPT}"
	fi

	unpack ${A}
	cd ${S}
	# apply bulk patches
	if [[ -n "${PATCHES}" ]] ; then
		for p in ${PATCHES} ; do
			epatch $p
		done
	fi
}

ruby-gnome2_src_compile() {
	ruby extconf.rb || die "extconf.rb failed"
	emake CC=${CC:-gcc} CXX=${CXX:-g++} || die "emake failed"
}

ruby-gnome2_src_install() {
	dodir $(ruby -r rbconfig -e 'print Config::CONFIG["sitearchdir"]')
	make DESTDIR=${D} install || die "make install failed"
	for doc in ../AUTHORS ../NEWS ChangeLog README; do
		[ -s "$doc" ] && dodoc $doc
	done
	if [[ -d sample ]]; then
		dodir /usr/share/doc/${PF}
		cp -a sample ${D}/usr/share/doc/${PF} || die "cp failed"
	fi
}
