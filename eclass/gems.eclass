# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gems.eclass,v 1.14 2007/01/09 23:29:17 flameeyes Exp $
#
# Author: Rob Cakebread <pythonhead@gentoo.org>
# Current Maintainer: Ruby Herd <ruby@gentoo.org>
#
# The gems eclass is designed to allow easier installation of
# gems-based ruby packagess and their incorporation into
# the Gentoo Linux system.
#
# - Features:
# gems_location()	  - Set ${GEMSDIR} with gem install dir and ${GEM_SRC} with path to gem to install
# gems_src_install()  - installs a gem into ${ED}
# gems_src_unpack()	  - Does nothing.
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
	GEMSDIR=${sitelibdir/site_ruby/gems}
	export GEMSDIR=${GEMSDIR#${EPREFIX%/}}

}

gems_src_unpack() {
	true
}

gems_src_install() {
	gems_location

	if [ -z "${MY_P}" ]; then
		GEM_SRC=${DISTDIR}/${P}
		spec_path=${ED}/${GEMSDIR}/specifications/${P}.gemspec
	else
		GEM_SRC=${DISTDIR}/${MY_P}
		spec_path=${ED}/${GEMSDIR}/specifications/${MY_P}.gemspec
	fi

	if use doc; then
		myconf="--rdoc"
	else
		myconf="--no-rdoc"
	fi

	# RI documentation installation: bug #145222
	if gem --version|grep -q ^0.9; then
		if use doc; then
			myconf="--ri ${myconf}"
		else
			myconf="--no-ri ${myconf}"
		fi
	fi


	dodir ${GEMSDIR}
	gem install ${GEM_SRC} -v ${PV} ${myconf} -l -i ${ED}/${GEMSDIR} || die "gem install failed: gem-$(gem --version) install ${GEM_SRC} -v ${PV} ${myconf} -l -i ${ED}/${GEMSDIR}"

	# This is a workaround for <=rubygems-0.9.0.8 because it's exitstatus equals 0
	# even if the dependencies are not found. So we are testing if rubygems at
	# least installed the gemspec (which should always occur otherwise).
	# See bug #104733
	test -f ${spec_path} || die "gem install failed (spec file ${spec_path} missing)"

	if [ -d ${ED}/${GEMSDIR}/bin ] ; then
		exeinto /usr/bin
		for exe in ${ED}/${GEMSDIR}/bin/* ; do
			doexe ${exe}
		done
	fi
}

gems_src_compile() {
	true
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
