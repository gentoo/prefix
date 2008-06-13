# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-tasks/ant-tasks-1.7.0-r4.ebuild,v 1.5 2008/03/03 00:55:03 wltjr Exp $

EAPI="prefix 1"

inherit java-pkg-2 eutils

DESCRIPTION="Meta-package for Apache Ant's optional tasks."
HOMEPAGE="http://ant.apache.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="X +antlr +bcel +bsf +commonslogging +commonsnet jai +javamail +jdepend jmf +jsch
	+log4j +oro +regexp +resolver"

RDEPEND=">=virtual/jre-1.4
	~dev-java/ant-core-${PV}
	~dev-java/ant-nodeps-${PV}
	~dev-java/ant-junit-${PV}
	!dev-java/ant-optional
	~dev-java/ant-trax-${PV}
	antlr? ( ~dev-java/ant-antlr-${PV} )
	bcel? ( ~dev-java/ant-apache-bcel-${PV} )
	bsf? ( ~dev-java/ant-apache-bsf-${PV} )
	log4j? ( ~dev-java/ant-apache-log4j-${PV} )
	oro? ( ~dev-java/ant-apache-oro-${PV} )
	regexp? ( ~dev-java/ant-apache-regexp-${PV} )
	resolver? ( ~dev-java/ant-apache-resolver-${PV} )
	commonslogging? ( ~dev-java/ant-commons-logging-${PV} )
	commonsnet? ( ~dev-java/ant-commons-net-${PV} )
	jai? ( ~dev-java/ant-jai-${PV} )
	javamail? ( ~dev-java/ant-javamail-${PV} )
	jdepend? ( ~dev-java/ant-jdepend-${PV} )
	jmf? ( ~dev-java/ant-jmf-${PV} )
	jsch? ( ~dev-java/ant-jsch-${PV} )
	X? ( ~dev-java/ant-swing-${PV} )"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}"

S="${WORKDIR}"

src_compile() { :; }

my_reg_jars() {
	# Recording jars to get the same behaviour as before
	local jars="$(java-pkg_getjars ${1})"
	for jar in ${jars//:/ }; do
		# these two are only for tasks, not core
		if [[ "${1}" != ant-core ]]; then
			# this one for package.env, thus java-config -p etc
			java-pkg_regjar "${jar}"
			# this one for broken stuff with hardcoded paths
			dosym ${jar} /usr/share/${PN}/lib/
		fi
		# this one for the non-split $ANT_HOME/lib expected by stuff that
		# doesn't use the launcher
		dosym ${jar} /usr/share/ant/lib/
	done
}

src_install() {
	# create the fake ANT_HOME with symlinks to all ant jars
	# starting with ant-core
	dodir /usr/share/ant/lib
	my_reg_jars ant-core
	# just in case
	dosym /usr/share/ant-core/bin /usr/share/ant/bin

	# now process the tasks
	my_reg_jars ant-nodeps
	my_reg_jars ant-junit
	my_reg_jars ant-trax
	use antlr && my_reg_jars ant-antlr
	use bcel && my_reg_jars ant-apache-bcel
	use bsf && my_reg_jars ant-apache-bsf
	use log4j && my_reg_jars ant-apache-log4j
	use oro && my_reg_jars ant-apache-oro
	use regexp && my_reg_jars ant-apache-regexp
	use resolver && my_reg_jars ant-apache-resolver
	use commonslogging && my_reg_jars ant-commons-logging
	use commonsnet && my_reg_jars ant-commons-net
	use jai && my_reg_jars ant-jai
	use javamail && my_reg_jars ant-javamail
	use jdepend && my_reg_jars ant-jdepend
	use jmf && my_reg_jars ant-jmf
	use jsch && my_reg_jars ant-jsch

	use X && my_reg_jars ant-swing

	# point ANT_HOME to the one with all symlinked jars
	# ant-core startup script will ignore this one anyway
	echo "ANT_HOME=\"${EPREFIX}/usr/share/ant\"" > "${T}/21ant-tasks"
	doenvd "${T}/21ant-tasks" || die "failed to install env.d file"
}

pkg_postinst() {
	elog "You may now freely set the USE flags of this package without breaking"
	elog "building of Java packages, which DEPEND on the exact tasks they need."
	elog "The USE flags default to enabled except X, jai and jmf for convenience."
}
