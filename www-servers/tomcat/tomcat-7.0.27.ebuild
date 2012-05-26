# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/tomcat/tomcat-7.0.27.ebuild,v 1.2 2012/05/02 17:17:22 ago Exp $

EAPI=2
JAVA_PKG_IUSE="doc examples source test"
WANT_ANT_TASKS="ant-trax"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Tomcat Servlet-3.0/JSP-2.2 Container"

MY_P="apache-${P}-src"
SLOT="7"
SRC_URI="mirror://apache/${PN}/${PN}-${SLOT}/v${PV}/src/${MY_P}.tar.gz"
HOMEPAGE="http://tomcat.apache.org/"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
LICENSE="Apache-2.0"

IUSE=""

ECJV="3.7"

# servlet-api slot
SAPIS="3.0"

COMMON_DEPEND="dev-java/eclipse-ecj:${ECJV}
	dev-java/ant-eclipse-ecj:${ECJV}
	>=dev-java/commons-dbcp-1.4
	>=dev-java/commons-logging-1.1
	>=dev-java/commons-pool-1.5.5
	~dev-java/tomcat-servlet-api-${PV}
	examples? ( dev-java/jakarta-jstl )"

RDEPEND="
	!<dev-java/tomcat-native-1.1.20
	>=virtual/jre-1.6
	>=dev-java/commons-daemon-1.0.9
	dev-java/ant-core
	${COMMON_DEPEND}"

DEPEND=">=virtual/jdk-1.6
	${COMMON_DEPEND}
	test? ( =dev-java/junit-3.8* )"

S=${WORKDIR}/${MY_P}

TOMCAT_NAME="${PN}-${SLOT}"
TOMCAT_HOME="/usr/share/${TOMCAT_NAME}"
WEBAPPS_DIR="/var/lib/${TOMCAT_NAME}/webapps"

# TODO: Fails to find PrettyPrint in with python 2.6 and xml-rewriter-3
# Find out why so
JAVA_ANT_CELEMENT_REWRITER="true"
JAVA_ANT_REWRITE_CLASSPATH="true"

EANT_NEEDS_TOOLS="true"
EANT_GENTOO_CLASSPATH="tomcat-servlet-api-${SAPIS},eclipse-ecj-${ECJV}"

EANT_BUILD_TARGET="package"
EANT_DOC_TARGET="build-docs"

EANT_EXTRA_ARGS="-Dbase.path=${T} -Dversion=${PV}-gentoo -Dversion.number=${PV}
-Dcompile.debug=false -Del-api.jar=el-api.jar -Djsp-api.jar=jsp-api.jar -Dservlet-api.jar=servlet-api.jar
-Dant.jar=ant.jar"

pkg_setup() {
	java-pkg-2_pkg_setup
	enewgroup tomcat 265
	enewuser tomcat 265 -1 /dev/null tomcat
}

java_prepare() {
	epatch "${FILESDIR}/${SLOT}/${PV}-build-xml.patch"

	rm -v webapps/examples/WEB-INF/lib/*.jar \
		test/webapp-3.0-fragments/WEB-INF/lib/*.jar || die

	# bug # 178980 and #312293
	use amd64 && java-pkg_force-compiler eclipse-ecj-${ECJV}

	if ! use doc; then
		EANT_EXTRA_ARGS+=" -Dnobuild.docs=true"
	fi

	EANT_EXTRA_ARGS+=" -Djdt.jar=$(java-pkg_getjar eclipse-ecj-${ECJV} ecj.jar)"
	java-pkg_jarfrom --build-only ant-core ant.jar
}

src_install() {
	cd "${S}/bin"
	rm -f *.bat
	chmod 755 *.sh

	# register jars per bug #171496
	cd "${S}/output/build/lib/"
	for jar in *.jar; do
		java-pkg_dojar ${jar}
	done

	local CATALINA_BASE=/var/lib/${TOMCAT_NAME}/

	# init.d, conf.d
	newinitd "${FILESDIR}"/${SLOT}/tomcat.init ${TOMCAT_NAME}
	newconfd "${FILESDIR}"/${SLOT}/tomcat.conf ${TOMCAT_NAME}

	# create dir structure
	dodir /usr/share/${TOMCAT_NAME}

	use prefix \
		&& diropts -m750 \
		|| diropts -m750 -o tomcat -g tomcat
	dodir   /etc/${TOMCAT_NAME}
	keepdir ${WEBAPPS_DIR}

	use prefix \
		&& diropts -m750 \
		|| diropts -m750 -o tomcat -g tomcat
	dodir   ${CATALINA_BASE}

	use prefix \
		&& diropts -m750 \
		|| diropts -m750 -o tomcat -g tomcat
	dodir   /etc/${TOMCAT_NAME}/Catalina/localhost
	keepdir /var/log/${TOMCAT_NAME}/
	keepdir /var/run/${TOMCAT_NAME}/
	keepdir /var/tmp/${TOMCAT_NAME}/

	cd "${S}"
	# fix context's so webapps will be deployed
	sed -i -e 's:Context a:Context docBase="${catalina.home}/webapps/host-manager"  a:' "${S}"/webapps/host-manager/META-INF/context.xml
	sed -i -e 's:Context a:Context docBase="${catalina.home}/webapps/manager"  a:' "${S}"/webapps/manager/META-INF/context.xml

	# replace the default pw with a random one, see #92281
	local randpw=$(echo ${RANDOM}|md5sum|cut -c 1-15)
	sed -e s:SHUTDOWN:${randpw}: -i conf/server.xml

	# copy over the directories
	use prefix || chown -R tomcat:tomcat webapps/* conf/*
	cp -pR conf/* "${ED}"/etc/${TOMCAT_NAME} || die "failed to copy conf"
	cp -pPR output/build/bin "${ED}"/usr/share/${TOMCAT_NAME} \
		|| die "failed to copy"
	# webapps get stored in /usr/share/${TOMCAT_NAME}/webapps
	cd "${S}"/webapps || die
	ebegin "Installing webapps to /usr/share/${TOMCAT_NAME}"

	dodir /usr/share/${TOMCAT_NAME}/webapps
	cp -pR ROOT "${ED}"/usr/share/${TOMCAT_NAME}/webapps || die
	cp -pR host-manager "${ED}"/usr/share/${TOMCAT_NAME}/webapps || die
	cp -pR manager "${ED}"/usr/share/${TOMCAT_NAME}/webapps || die
	if use doc; then
		cp -pR "${S}"/output/build/webapps/docs "${ED}"/usr/share/${TOMCAT_NAME}/webapps || die
	fi
	if use examples; then
		cd "${S}"/webapps/examples/WEB-INF/lib
		java-pkg_jar-from jakarta-jstl jstl.jar
		java-pkg_jar-from jakarta-jstl standard.jar
		cd "${S}"/webapps
		cp -pR examples "${ED}"/usr/share/${TOMCAT_NAME}/webapps || die
	fi

	# replace catalina.policy with gentoo specific one bug #176701
#	cp ${FILESDIR}/${SLOT}/catalina.policy "${ED}"/etc/${TOMCAT_NAME} \
#		|| die "failed to replace catalina.policy"

	cd "${ED}/usr/share/${TOMCAT_NAME}/lib" || die
	java-pkg_jar-from eclipse-ecj-${ECJV}
	java-pkg_jar-from tomcat-servlet-api-${SAPIS}

	# symlink the directories to make CATALINA_BASE possible
	dosym /etc/${TOMCAT_NAME} ${CATALINA_BASE}/conf
	dosym /var/log/${TOMCAT_NAME} ${CATALINA_BASE}/logs
	dosym /var/tmp/${TOMCAT_NAME} ${CATALINA_BASE}/temp
	# we cannot symlink work directory because that breaks saving session data
	# because session file cannot be saved to symlinked location by default
	#dosym /var/run/${TOMCAT_NAME} ${CATALINA_BASE}/work

	dodoc  "${S}"/{RELEASE-NOTES,RUNNING.txt}
	fperms 640 /etc/${TOMCAT_NAME}/tomcat-users.xml

	#install *.sh scripts bug #278059
	exeinto /usr/share/${TOMCAT_NAME}/bin
	doexe "${S}"/bin/*.sh
}

pkg_postinst() {
	ewarn "Changing ownership recursively on /etc/${TOMCAT_NAME}"
	# temp fix for bug #176097
	use prefix || chown -fR tomcat:tomcat /etc/${TOMCAT_NAME}
	ewarn "Owner ship changed to tomcat:tomcat. Temp hack/fix."

	# bug #180519
	if [[ -e "${EROOT}var/lib/${TOMCAT_NAME}/webapps/manager" ]] ; then
		elog
		elog "The latest webapp has NOT been installed into"
		elog "${EROOT}var/lib/${TOMCAT_NAME}/webapps/ because directory already exists"
		elog "and we do not want to overwrite any files you have put there."
		elog
		elog "Installing latest webapp into"
		elog "${EROOT}usr/share/${TOMCAT_NAME}/webapps instead"
		elog
		elog "Manager Symbolic Links NOT created."
	else
		einfo "Installing latest webroot to ${EROOT}/${WEBAPPS_DIR}"
		cp -pR "${EROOT}"/usr/share/${TOMCAT_NAME}/webapps/* \
			"${EROOT}""${WEBAPPS_DIR}"
		# link the manager's context to the right position
		dosym ${TOMCAT_HOME}/webapps/host-manager/META-INF/context.xml /etc/${TOMCAT_NAME}/Catalina/localhost/host-manager.xml
		dosym ${TOMCAT_HOME}/webapps/manager/META-INF/context.xml /etc/${TOMCAT_NAME}/Catalina/localhost/manager.xml
	fi

	# bug with storing SESSIONS.ser file to path with symlink
	if [[ -L "${EROOT}var/lib/${TOMCAT_NAME}/work" ]] ; then
		elog
		ewarn "${EROOT}var/lib/${TOMCAT_NAME}/work is symbolic link which breaks"
		ewarn "storing of SESSIONS.ser files in work directory when allowLinking"
		ewarn "is disabled (the default). Remove the symbolic link (while Tomcat is"
		ewarn "not running) to fix the issue."
	fi

	elog
	elog " This ebuild implements a FHS compliant layout for tomcat"
	elog " Please read http://www.gentoo.org/proj/en/java/tomcat6-guide.xml"
	elog " for more information."
	elog
	ewarn "tomcat-dbcp.jar is not built at this time. Please fetch jar"
	ewarn "from upstream binary if you need it. Gentoo Bug # 144276"
	elog

	ewarn "The manager webapps have known exploits, please refer to"
	ewarn "http://cve.mitre.org/cgi-bin/cvename.cgi?name=2007-2450"

	if use examples ; then
		ewarn
		ewarn "The examples webapp has a known exploit, please refer to"
		ewarn "http://cve.mitre.org/cgi-bin/cvename.cgi?name=2007-2449"
		ewarn
	fi

	elog
	elog " Please report any bugs to http://bugs.gentoo.org/"
	elog
}
