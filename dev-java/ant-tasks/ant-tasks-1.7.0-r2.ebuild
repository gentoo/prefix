# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-tasks/ant-tasks-1.7.0-r2.ebuild,v 1.7 2007/10/30 01:20:18 betelgeuse Exp $

EAPI="prefix"

inherit java-pkg-2 eutils

DESCRIPTION="Meta-package for Apache Ant's optional tasks."
HOMEPAGE="http://ant.apache.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="jai javamail noantlr nobcel nobsf nocommonsnet nocommonslogging nojdepend
	nojmf nojsch nolog4j nooro noregexp noresolver noswing noxalan"
# nobeanutils nobsh nojython norhino noxerces

RDEPEND=">=virtual/jre-1.4
	~dev-java/ant-core-${PV}
	~dev-java/ant-nodeps-${PV}
	~dev-java/ant-junit-${PV}
	!dev-java/ant-optional
	!noantlr? ( ~dev-java/ant-antlr-${PV} )
	!nobcel? ( ~dev-java/ant-apache-bcel-${PV} )
	!nobsf? ( ~dev-java/ant-apache-bsf-${PV} )
	!nolog4j? ( ~dev-java/ant-apache-log4j-${PV} )
	!nooro? ( ~dev-java/ant-apache-oro-${PV} )
	!noregexp? ( ~dev-java/ant-apache-regexp-${PV} )
	!noresolver? ( ~dev-java/ant-apache-resolver-${PV} )
	!nocommonslogging? ( ~dev-java/ant-commons-logging-${PV} )
	!nocommonsnet? ( ~dev-java/ant-commons-net-${PV} )
	jai? ( ~dev-java/ant-jai-${PV} )
	javamail? ( ~dev-java/ant-javamail-${PV} )
	!nojdepend? ( ~dev-java/ant-jdepend-${PV} )
	!nojmf? ( ~dev-java/ant-jmf-${PV} )
	!nojsch? ( ~dev-java/ant-jsch-${PV} )
	!noswing? ( ~dev-java/ant-swing-${PV} )
	!noxalan? ( ~dev-java/ant-trax-${PV} )"

# 	TODO: consider those
# 	!noxerces? ( >=dev-java/xerces-2.6.2-r1 )
# 	!nobsh? ( >=dev-java/bsh-1.2-r7 )
# 	!nobeanutils? ( =dev-java/commons-beanutils-1.6* )
# 	!norhino? ( =dev-java/rhino-1.5* )
# 	!nojython? ( >=dev-java/jython-2.1-r5 )

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
	use !noantlr && my_reg_jars ant-antlr
	use !nobcel && my_reg_jars ant-apache-bcel
	use !nobsf && my_reg_jars ant-apache-bsf
	use !nolog4j && my_reg_jars ant-apache-log4j
	use !nooro && my_reg_jars ant-apache-oro
	use !noregexp && my_reg_jars ant-apache-regexp
	use !noresolver && my_reg_jars ant-apache-resolver
	use !nocommonslogging && my_reg_jars ant-commons-logging
	use !nocommonsnet && my_reg_jars ant-commons-net
	use jai && my_reg_jars ant-jai
	use javamail && my_reg_jars ant-javamail
	use !nojdepend && my_reg_jars ant-jdepend
	use !nojmf && my_reg_jars ant-jmf
	use !nojsch && my_reg_jars ant-jsch
	my_reg_jars ant-junit
	use !noswing && my_reg_jars ant-swing
	use !noxalan && my_reg_jars ant-trax

	# point ANT_HOME to the one with all symlinked jars
	# ant-core startup script will ignore this one anyway
	echo "ANT_HOME=\"${EPREFIX}/usr/share/ant\"" > "${T}/21ant-tasks"
	doenvd "${T}/21ant-tasks" || die "failed to install env.d file"
}

pkg_postinst() {
	local noset=false
	for x in ${IUSE} ; do
		if [ "${x:0:2}" == "no" ] ; then
			use ${x} && noset=true
		fi
	done
	if [ ${noset} == "true" ]; then
		ewarn "You have disabled some of the ant tasks. Be advised that this may"
		ewarn "break building some of the Java packages!!"
		ewarn ""
		ewarn "We can only offer very limited support in cases where dev-java/ant-tasks"
		ewarn "has been build with essential features disabled."
	fi
}
