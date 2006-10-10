# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/games-etmod.eclass,v 1.12 2006/10/02 06:31:40 mr_bones_ Exp $

inherit games

EXPORT_FUNCTIONS src_install pkg_postinst

DESCRIPTION="Enemy Territory - ${MOD_DESC}"

SLOT="0"
KEYWORDS="-* amd64 x86"
RESTRICT="nostrip"
IUSE="opengl dedicated"

DEPEND="app-arch/unzip"
RDEPEND="sys-libs/glibc
	games-fps/enemy-territory
	amd64? ( app-emulation/emul-linux-x86-baselibs
		opengl? ( app-emulation/emul-linux-x86-xlibs ) )
	dedicated? ( app-misc/screen )
	opengl? ( virtual/opengl )"

S=${WORKDIR}

games-etmod_src_install() {
	[ -z "${MOD_NAME}" ] && die "what is the name of this etmod ?"

	local bdir=${GAMES_PREFIX_OPT}/enemy-territory
	local mdir=${bdir}/${MOD_NAME}
	MOD_BINS=${MOD_BINS:-${MOD_NAME}}

	if [ -d ${MOD_NAME} ] ; then
		dodir "${bdir}"
		cp -PR ${MOD_NAME} "${D}/${bdir}/"
	fi
	if [ -d etmain ] ; then
		dodir "${bdir}"
		cp -PR etmain "${D}/${bdir}/"
	fi
	if [ ! -z "`ls "${S}"/* 2> /dev/null`" ] ; then
		dodir "${mdir}"
		cp -PR "${S}"/* "${D}/${mdir}/"
	fi

	if use dedicated; then
		games-etmod_make_etded_exec
		newgamesbin "${T}"/et-${MOD_NAME}-ded.bin et-${MOD_BINS}-ded
	fi
	if use opengl; then
		games-etmod_make_enemy-territory_exec
		newgamesbin "${T}"/et-${MOD_NAME}.bin et-${MOD_BINS}
	fi

	if use dedicated; then
		games-etmod_make_init.d
		newinitd "${T}"/et-${MOD_NAME}-ded.init.d et-${MOD_BINS}-ded
		games-etmod_make_conf.d
		newconfd "${T}"/et-${MOD_NAME}-ded.conf.d et-${MOD_BINS}-ded

		dodir "${GAMES_SYSCONFDIR}"/enemy-territory

		dodir "${bdir}"/etwolf-homedir
		dosym "${bdir}"/etwolf-homedir "${GAMES_PREFIX}"/.wolfet
		keepdir ${bdir}/etwolf-homedir
		chmod g+rw "${D}/${mdir}" "${D}/${bdir}"/etwolf-homedir
		chmod -R g+rw "${D}/${GAMES_SYSCONFDIR}"/enemy-territory
	fi
	prepgamesdirs
}

games-etmod_pkg_postinst() {
	local samplecfg=${FILESDIR}/server.cfg
	local realcfg=${GAMES_PREFIX_OPT}/enemy-territory/${MOD_NAME}/server.cfg

	if [ -e "${samplecfg}" ] && [ ! -e "${realcfg}" ] ; then
		cp "${samplecfg}" "${realcfg}"
	fi

	use opengl && einfo "To play this mod:             et-${MOD_BINS}"
	if use dedicated; then
		einfo "To launch a dedicated server: et-${MOD_BINS}-ded"
		einfo "To launch server at startup:  /etc/init.d/et-${MOD_NAME}-ded"
	fi

	games_pkg_postinst
}

games-etmod_make_etded_exec() {
cat << EOF > "${T}"/et-${MOD_NAME}-ded.bin
#!/bin/sh
exec ${GAMES_BINDIR}/et-ded +set fs_game ${MOD_NAME} +set dedicated 1 +exec server.cfg \${@}
EOF
}

games-etmod_make_enemy-territory_exec() {
cat << EOF > "${T}"/et-${MOD_NAME}.bin
#!/bin/sh
exec "${GAMES_BINDIR}"/et +set fs_game ${MOD_NAME} \${@}
EOF
}

games-etmod_make_init.d() {
cat << EOF > "${T}"/et-${MOD_NAME}-ded.init.d
#!/sbin/runscript
$(<${PORTDIR}/header.txt)

depend() {
	need net
}

start() {
	ebegin "Starting ${MOD_NAME} dedicated"
	screen -A -m -d -S et-${MOD_BINS}-ded su - ${GAMES_USER_DED} -c "${GAMES_BINDIR}/et-${MOD_BINS}-ded \${${MOD_NAME}_OPTS}"
	eend \$?
}

stop() {
	ebegin "Stopping ${MOD_NAME} dedicated"
	local pid=\`screen -list | grep et-${MOD_BINS}-ded | awk -F . '{print \$1}' | sed -e s/.//\`
	if [ -z "\${pid}" ] ; then
		eend 1 "Lost screen session"
	else
		pid=\`pstree -p \${pid} | sed -e 's:^.*etded\.x86::'\`
		pid=\${pid:1:\${#pid}-2}
		if [ -z "\${pid}" ] ; then
			eend 1 "Lost etded session"
		else
			kill \${pid}
			eend \$? "Could not kill etded"
		fi
	fi
}

status() {
	screen -list | grep et-${MOD_BINS}-ded
}
EOF
}

games-etmod_make_conf.d() {
	if [ -e "${FILESDIR}"/${MOD_NAME}.conf.d ] ; then
		cp "${FILESDIR}"/${MOD_NAME}.conf.d "${T}"/et-${MOD_NAME}-ded.conf.d
		return 0
	fi
cat << EOF > "${T}"/et-${MOD_NAME}-ded.conf.d
$(<${PORTDIR}/header.txt)

# Any extra options you want to pass to the dedicated server
${MOD_NAME}_OPTS="+set com_hunkmegs 64 +set com_zonemegs 32"
EOF
}
