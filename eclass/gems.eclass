# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gems.eclass,v 1.9 2006/06/15 12:40:08 caleb Exp $
#
# Author: Rob Cakebread <pythonhead@gentoo.org>
# Current Maintainer: Ruby Herd <ruby@gentoo.org>
#
# The gems eclass is designed to allow easier installation of
# gems-based ruby packagess and their incorporation into
# the Gentoo Linux system.
#
# - Features:
# gems_location()     - Set ${GEMSDIR} with gem install dir and ${GEM_SRC} with path to gem to install
# gems_src_install()  - installs a gem into ${D}
# gems_src_unpack()   - Does nothing.
# gems_src_compile()  - Does nothing.
#
# NOTE:
# See http://dev.gentoo.org/~pythonhead/ruby/gems.html for notes on using gems with portage


inherit ruby eutils


DEPEND=">=dev-ruby/rubygems-0.8.4-r1
	!dev-ruby/rdoc"

S=${WORKDIR}

IUSE="doc"

gems_location() {
	local sitelibdir
	sitelibdir=`ruby -r rbconfig -e 'print Config::CONFIG["sitelibdir"]'`
	export GEMSDIR=${sitelibdir/site_ruby/gems}

}

gems_src_unpack() {
	true
}

gems_src_install() {
	gems_location

	if [ -z "${MY_P}" ]; then
		GEM_SRC=${DISTDIR}/${P}
	else
		GEM_SRC=${DISTDIR}/${MY_P}
	fi

	if use doc; then
		myconf="--rdoc"
	else
		myconf="--no-rdoc"
	fi

	dodir ${GEMSDIR}
	gem install ${GEM_SRC} -v ${PV} ${myconf} -l -i ${D}/${GEMSDIR} || die "gem install failed"

	if [ -d ${D}/${GEMSDIR}/bin ] ; then
		exeinto /usr/bin
		for exe in ${D}/${GEMSDIR}/bin/* ; do
			doexe ${exe}
		done
	fi
}

gems_src_compile() {
	true
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
