# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_SUPPORTS_GENERATION_1="true"
inherit java-vm-2

DESCRIPTION="Landon Fuller's Java for Mac OS X"
HOMEPAGE="http://landonf.bikemonkey.org/static/soylatte/"
SLOT="1.6"
LICENSE="sun-jrl"
KEYWORDS="~x86-macos"

JAVA_PROVIDE="jdbc-stdext"

RESTRICT="fetch"

DOWNLOADSITE="http://landonf.bikemonkey.org/static/soylatte/"

MY_P=soylatte16-i386-${PV}
SRC_URI="${MY_P}.tar.bz2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	#fix install_names
	local original_root=/data/Users/landonf/Documents/Code/Java/javasrc_1_6_jrl_darwin_stable/control/build/bsd-i586
	local original_demo=${original_root}/demo
	local original_lib=${original_root}/lib
	for dir in demo jre; do
		for dynamic_lib in $(find ${dir} -name '*.dylib'); do
			install_name_tool -id "${EPREFIX}"/opt/${P}/${dynamic_lib} ${dynamic_lib}
			for linked_against in $(otool -LX ${dynamic_lib} | awk '{print $1}' | grep "^${original_root}"); do
				case ${linked_against} in
					${original_lib}*)
						install_name_tool -change \
							${linked_against} \
							"${EPREFIX}"/opt/${P}/jre/${linked_against#${original_root}} \
							${dynamic_lib};;
					${original_demo}*)
						install_name_tool -change \
							${linked_against} \
							"${EPREFIX}"/opt/${P}/${linked_against#${original_root}} \
							${dynamic_lib};;
				esac
			done
		done
	done
	# this file links against non-existant dynamic libraries:
	# 	jre/lib/i386/libJdbcOdbc.dylib:
	#		${original_root}/tmp/sun/sun.jdbc.odbc/JdbcOdbc/libodbcinst.dylib
	#		${original_root}/tmp/sun/sun.jdbc.odbc/JdbcOdbc/libodbc.dylib
	# a couple of files link against libjvm.dylib -- there's a server version
	# and a client version, though. which one should it link against?
}

src_install() {
	local dirs="bin include jre lib man"
	dodir /opt/${P}

	cp -pPR $dirs "${ED}/opt/${P}/" || die "failed to copy"
	dodoc COPYRIGHT || die
	dohtml README.html || die

	cp -pP src.zip "${ED}/opt/${P}/" || die

	if use examples; then
		cp -pPR demo sample "${ED}/opt/${P}/" || die
	fi

	# create dir for system preferences
	dodir /opt/${P}/jre/.systemPrefs
	# Create files used as storage for system preferences.
	touch "${ED}"/opt/${P}/jre/.systemPrefs/.system.lock
	chmod 644 "${ED}"/opt/${P}/jre/.systemPrefs/.system.lock
	touch "${ED}"/opt/${P}/jre/.systemPrefs/.systemRootModFile
	chmod 644 "${ED}"/opt/${P}/jre/.systemPrefs/.systemRootModFile

	set_java_env
}
