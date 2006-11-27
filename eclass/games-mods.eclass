# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/games-mods.eclass,v 1.11 2006/11/21 23:27:35 wolf31o2 Exp $

# Variables to specify in an ebuild which uses this eclass:
# GAME - (doom3, quake4 or ut2004, etc), unless ${PN} starts with e.g. "doom3-"
# MOD_BINS - Name of the binary to run
# MOD_DESC - Description for the mod
# MOD_DIR - Subdirectory name for the mod, if applicable
# MOD_ICON - Custom icon for the mod, instead of the default
# MOD_NAME - Creates a command-line wrapper and desktop icon for the mod
# MOD_TBZ2 - File to extract within the Makeself archive

inherit eutils games

EXPORT_FUNCTIONS pkg_setup src_unpack src_install pkg_postinst

[[ -z ${GAME} ]] && GAME=${PN%%-*}

# Set our default title, icon, and cli options
case "${GAME}" in
	"doom3")
		GAME_TITLE="Doom III"
		DEFAULT_MOD_ICON="doom3.png"
		SELECT_MOD="+set fs_game "
		GAME_EXE="doom3"
		DED_EXE="doom3-ded"
		DED_OPTIONS="+set dedicated 1 +exec server.cfg"
		;;
	"enemy-territory")
		GAME_TITLE="Enemy Territory"
		DEFAULT_MOD_ICON="ET.xpm"
		SELECT_MOD="+set fs_game "
		GAME_EXE="et"
		DED_EXE="et-ded"
		DED_OPTIONS="+set dedicated 1 +exec server.cfg"
		;;
	"quake3")
		GAME_TITLE="Quake III"
		DEFAULT_MOD_ICON="quake3.xpm"
		SELECT_MOD="+set fs_game "
		GAME_EXE="quake3"
		DED_EXE="quake3-ded"
		DED_OPTIONS="+set dedicated 1 +exec server.cfg"
		;;
	"quake4")
		GAME_TITLE="Quake IV"
		DEFAULT_MOD_ICON="quake4.bmp"
		SELECT_MOD="+set fs_game "
		GAME_EXE="q4"
		DED_EXE="q4-ded"
		DED_OPTIONS="+set dedicated 1 +exec server.cfg"
		;;
	"ut2003")
		GAME_TITLE="UT2003"
		DEFAULT_MOD_ICON="ut2003.xpm"
		SELECT_MOD="-mod="
		GAME_EXE="ut2003"
		DED_EXE="ucc"
		DED_OPTIONS=""
		;;
	"ut2004")
		GAME_TITLE="UT2004"
		DEFAULT_MOD_ICON="ut2004.xpm"
		SELECT_MOD="-mod="
		GAME_EXE="ut2004"
		DED_EXE="ucc"
		DED_OPTIONS=""
		;;
	*)
		eerror "This game is either not supported or you must set the GAME"
		eerror "variable to the proper game."
		die "unsupported game"
		;;
esac

DESCRIPTION="${GAME_TITLE} ${MOD_NAME} - ${MOD_DESC}"

SLOT="0"
LICENSE="freedist"
KEYWORDS="-* amd64 x86"
IUSE="dedicated opengl"
RESTRICT="mirror strip"

DEPEND="app-arch/unzip"
#RDEPEND="${CATEGORY}/${GAME}"

S=${WORKDIR}

dir=${GAMES_DATADIR}/${GAME}
Ddir=${D}/${dir}

default_client() {
	if use opengl || ! use dedicated
	then
		# Use opengl by default
		return 0
	else
		return 1
	fi
}

games-mods_pkg_setup() {
	[[ -z "${MOD_NAME}" ]] && die "what is the name of this mod?"

	games_pkg_setup

	if has_version ${CATEGORY}/${GAME}
	then
		if use dedicated && ! built_with_use ${CATEGORY}/${GAME} dedicated
		then
			die "You must merge ${CATEGORY}/${GAME} with USE=dedicated!"
		fi
		if has_version ${CATEGORY}/${GAME}-bin
		then
			if use dedicated && \
			! built_with_use ${CATEGORY}/${GAME}-bin dedicated
			then
				die "You must merge ${CATEGORY}/${GAME}-bin with USE=dedicated!"
			fi
		fi
	elif has_version ${CATEGORY}/${GAME}-bin
	then
		if use dedicated && ! built_with_use ${CATEGORY}/${GAME}-bin dedicated
		then
			die "You must merge ${CATEGORY}/${GAME}-bin with USE=dedicated!"
		fi
	else
		die "${CATEGORY}/${GAME} not installed!"
	fi
}

games-mods_src_unpack() {
	# The first thing we do here is determine exactly what we're dealing with
	for src_uri in ${A}
	do
		URI_SUFFIX="${src_uri##*.}"
		case ${URI_SUFFIX##*.} in
			bin|run)
				# We have a Makeself archive, use unpack_makeself
				unpack_makeself "${src_uri}"
				# Since this is a Makeself archive, it has a lot of useless
				# files (for us), so we delete them.
				rm -rf setup.data setup.sh uninstall
				;;
			bz2|gz|Z|z|ZIP|zip)
				# We have a normal tarball/zip file, use unpack
				unpack "${src_uri}"
				;;
		esac
	done

	# This code should only be executed for Makeself archives
	for tarball in ${MOD_TBZ2}
	do
		mkdir -p "${S}"/unpack
		for name in "${tarball}_${PV}-english" "${tarball}_${PV}" "${tarball}"
		do
			for ext in tar.bz2 tar.gz tbz2 tgz
			do
				if [[ -e "${name}.${ext}" ]]
				then
					tar xf "${name}.${ext}" -C "${S}"/unpack \
						|| die "uncompressing tarball"
					# Remove the tarball after we unpack it
					rm -f "${name}.${ext}"
				fi
			done
		done
	done
	# Since we remove all of these anyway, let's move it to the eclass
	rm -f 3355_patch
}

games-mods_src_install() {
	local readme MOD_ICON_EXT new_bin_name bin_name mod files directories i j
	INS_DIR=${dir}

	# We check if we have a specific MOD_DIR listed
	if [[ -n "${MOD_DIR}" ]]
	then
		# Am installing into a new subdirectory of the game
		if [[ -d "${S}"/unpack/"${MOD_DIR}" ]]
		then
			INS_DIR=${dir}
		elif [[ -d "${S}"/"${MOD_DIR}" ]]
		then
			S=${WORKDIR}/${MOD_DIR}
			INS_DIR=${dir}/${MOD_DIR}
		fi
	fi

	cd "${S}"

	# If we have a README, install it
	for readme in README*
	do
		if [[ -e "${readme}" ]]
		then
			dodoc "${readme}" || die "dodoc failed"
		fi
	done

	if default_client
	then
		if [[ -n "${MOD_ICON}" ]]
		then
			# Install custom icon
			MOD_ICON_EXT=${MOD_ICON##*.}
			newicon "${MOD_ICON}" "${PN}.${MOD_ICON_EXT}"
			case ${MOD_ICON_EXT} in
				bmp|ico)
					MOD_ICON=/usr/share/pixmaps/${PN}.${MOD_ICON_EXT}
					;;
				*)
					MOD_ICON=${PN}.${MOD_ICON_EXT}
					;;
			esac
		else
			# Use the game's standard icon
			MOD_ICON=${DEFAULT_MOD_ICON}
		fi

		# Set up command-line and desktop menu entries
		if [[ -n "${MOD_BINS}" ]]
		then
			for binary in ${MOD_BINS}
			do
				if [[ -n "${MOD_DIR}" ]]
				then
					games_make_wrapper "${GAME_EXE}-${MOD_BINS}" \
						"${GAME_EXE} ${SELECT_MOD}${MOD_DIR}" "${dir}" "${dir}"
					make_desktop_entry "${GAME_EXE}-${MOD_BINS}" \
						"${GAME_TITLE} - ${MOD_NAME}" "${MOD_ICON}"
				elif [[ -e "${S}"/bin/"${binary}" ]]
				then
					exeinto "${dir}"
					newexe bin/${binary} ${GAME_EXE}-${binary} \
						|| die "newexe failed"
					new_bin_name=
					bin_name=$(echo ${binary} | sed -e 's:[-_.]: :g')
					# We want our wrapper to use the libraries/starting
					# directory of our game.  If the game is in
					# GAMES_PREFIX_OPT, then we want to start there.
					if [[ -d "${GAMES_PREFIX_OPT}"/${GAME} ]]
					then
						GAME_DIR="${GAMES_PREFIX_OPT}/${GAME}"
					else
						GAME_DIR="${dir}"
					fi
					games_make_wrapper "${GAME_EXE}-${binary}" \
						./"${GAME_EXE}-${binary}" "${GAME_DIR}" "${GAME_DIR}"
					if [[ "${bin_name}" == "${binary}" ]]
					then
						bin_name=${MOD_NAME}
					else
						for tmp1 in ${bin_name}
						do
							tmp2=$(echo ${tmp1} | cut -b1 | tr [[:lower:]] \
								[[:upper:]])
							tmp3=$(echo ${tmp1} | cut -b2-)
							new_bin_name="${new_bin_name} ${tmp2}${tmp3}"
						done
						new_bin_name=$(echo ${new_bin_name} | cut -b1-)
						bin_name="${MOD_NAME} (${new_bin_name})"
					fi
					make_desktop_entry "${GAME_EXE}-${binary}" \
						"${GAME_TITLE} - ${bin_name}" "${MOD_ICON}"
					# We remove the binary after we have installed it.
					rm -f bin/${binary}
				fi
			done
		# We don't want to leave the binary directory around
		rm -rf bin
		elif [[ -n "${MOD_DIR}" ]]
		then
			games_make_wrapper "${GAME_EXE}-${MOD_DIR}" \
				"${GAME_EXE} ${SELECT_MOD}${MOD_DIR}" "${dir}" "${dir}"
			make_desktop_entry "${GAME_EXE}-${MOD_DIR}" \
				"${GAME_TITLE} - ${MOD_NAME}" "${MOD_ICON}"
			# Since only quake3 has both a binary and a source-based install,
			# we only look for quake3 here.
			case "${GAME_EXE}" in
				"quake3")
					if has_version games-fps/quake3-bin
					then
						games_make_wrapper "${GAME_EXE}-bin-${MOD_DIR}" \
							"${GAME_EXE}-bin ${SELECT_MOD}${MOD_DIR}" \
							"${dir}" "${dir}"
					fi
					make_desktop_entry "${GAME_EXE}-bin-${MOD_DIR}" \
						"${GAME_TITLE} - ${MOD_NAME} (binary)" \
						"${MOD_ICON}"
				;;
			esac
		fi
	fi

	# Copy our unpacked files, if it exists
	if [[ -d "${S}"/unpack ]]
	then
		insinto "${INS_DIR}"
		doins -r "${S}"/unpack/* || die "copying files"
		rm -rf "${S}"/unpack
	fi

	# We expect anything not wanted to have been deleted by the ebuild
	if [[ ! -z $(ls "${S}"/* 2> /dev/null) ]]
	then
		insinto "${INS_DIR}"
		doins -r * || die "doins -r failed"
	fi

	# We are installing everything for these mods into ${INS_DIR}, which should
	# be ${GAMES_DATADIR}/${GAME}/${MOD_DIR} in most cases, and symlinking it
	# into ${GAMES_PREFIX_OPT}/${GAME}/${MOD_DIR} for each game.  This should
	# allow us to support both binary and source-based games easily.
	if [[ -d "${GAMES_PREFIX_OPT}"/"${GAME}" ]]
	then
		dodir "${GAMES_PREFIX_OPT}"/"${GAME}"
		mod=$(echo "${INS_DIR}" | sed -e "s:${GAMES_DATADIR}/${GAME}::" -e "s:^/::" )
		if [[ -z "${mod}" ]]
		then
			# Our mod doesn't have its own directory.  We now traverse the
			# directory structure and try to symlink everything to
			# GAMES_PREFIX_OPT/GAME so it'll work.
			directories=$(cd "${D}"/"${INS_DIR}";find . -maxdepth 1 -type d -printf '%P ')
			for i in ${directories}
			do
				if [[ -h "${GAMES_PREFIX_OPT}"/"${GAME}"/${i} ]]
				then
					# Skip this directory, and just run a symlink
					dosym "${INS_DIR}"/${i} \
						"${GAMES_PREFIX_OPT}"/"${GAME}"/${i} || die
				elif [[ -d "${GAMES_PREFIX_OPT}"/"${GAME}"/${i} ]]
				then
					dodir "${GAMES_PREFIX_OPT}"/"${GAME}"/${i}
					cd "${D}"/"${INS_DIR}"/${i}
					files="$(find . -type f -printf '%P ')"
					for j in ${files}
					do
						if has_version ${CATEGORY}/${PN}
						then
							dosym "${INS_DIR}"/${i}/${j} \
								"${GAMES_PREFIX_OPT}"/"${GAME}"/${i}/${j} \
								|| die
						elif [[ ! -e "${GAMES_PREFIX_OPT}"/"${GAME}"/${i}/${j} ]]
						then
							dosym "${INS_DIR}"/${i}/${j} \
								"${GAMES_PREFIX_OPT}"/"${GAME}"/${i}/${j} \
								|| die
						fi
					done
				else
					# Skip this directory, and just run a symlink
					dosym "${INS_DIR}"/${i} \
						"${GAMES_PREFIX_OPT}"/"${GAME}"/${i} || die
				fi
			done
			files=$(cd "${D}"/"${INS_DIR}";find . -maxdepth 1 -type f -printf '%P ')
			for i in ${files}
			do
				# Why don´t we use symlinks? Because these use ./$bin when
				# they run and that doesn't work if the binary is in
				# GAMES_PREFIX_OPT but the mod is in GAMES_DATADIR.
				#	dosym "${INS_DIR}"/${i} \
				#		"${GAMES_PREFIX_OPT}"/"${GAME}"/${i} || die
					cp -a "${D}"/"${INS_DIR}"/${i} \
						${D}/"${GAMES_PREFIX_OPT}"/"${GAME}"/${i} || die
			done
		elif [[ ! -f "${GAMES_PREFIX_OPT}"/"${GAME}"/${mod} ]]
		then
			elog "Creating symlink for ${mod}"
			dosym "${INS_DIR}" "${GAMES_PREFIX_OPT}"/"${GAME}" || die
		fi
	fi

	if use dedicated
	then
		dodir "${GAMES_STATEDIR}"
		if [[ -e ${FILESDIR}/server.cfg ]]
		then
			insinto "${GAMES_SYSCONFDIR}"/${GAME}/${MOD_DIR}
			doins ${FILESDIR}/server.cfg || die "Copying server config"
			case ${GAME} in
				doom3)
					dodir "${GAMES_PREFIX}"/.doom3/${MOD_DIR}
					dosym "${GAMES_SYSCONFDIR}"/${GAME}/${MOD_DIR}/server.cfg \
						"${GAMES_PREFIX}"/.doom3/${MOD_DIR}
					;;
				enemy-territory)
					dodir "${GAMES_PREFIX}"/.etwolf/${MOD_DIR}
					dosym "${GAMES_SYSCONFDIR}"/${GAME}/${MOD_DIR}/server.cfg \
						"${GAMES_PREFIX}"/.etwolf/${MOD_DIR}
					;;
				quake3)
					dodir "${GAMES_PREFIX}"/.q3a/${MOD_DIR}
					dosym "${GAMES_SYSCONFDIR}"/${GAME}/${MOD_DIR}/server.cfg \
						"${GAMES_PREFIX}"/.q3a/${MOD_DIR}
					;;
				quake4)
					dodir "${GAMES_PREFIX}"/.quake4/${MOD_DIR}
					dosym "${GAMES_SYSCONFDIR}"/${GAME}/${MOD_DIR}/server.cfg \
						"${GAMES_PREFIX}"/.quake4/${MOD_DIR}
					;;
			esac
		fi
		games-mods_make_ded_exec
		newgamesbin "${T}"/${GAME_EXE}-${MOD_DIR}-ded.bin \
			${GAME_EXE}-${MOD_DIR}-ded || die "dedicated"
		games-mods_make_init.d
		newinitd "${T}"/${GAME_EXE}-${MOD_DIR}-ded.init.d \
			${GAME_EXE}-${MOD_DIR}-ded || die "init.d"
		games-mods_make_conf.d
		newconfd "${T}"/${GAME_EXE}-${MOD_DIR}-ded.conf.d \
			${GAME_EXE}-${MOD_DIR}-ded || die "conf.d"
	fi

	prepgamesdirs
}

games-mods_pkg_postinst() {
	games_pkg_postinst
	if default_client
	then
		if [[ -n "${MOD_BINS}" ]]
		then
			for binary in ${MOD_BINS}
			do
				elog "To play this mod run:"
				elog " ${GAME_EXE}-${binary}"
				echo
			done
		elif [[ -n "${MOD_DIR}" ]]
		then
			elog "To play this mod run:"
			elog " ${GAME_EXE}-${MOD_DIR}"
			echo
		fi
	fi
	if use dedicated
	then
		elog "To launch a dedicated server run:"
		elog " ${GAME_EXE}-${MOD_DIR}-ded"
		echo
		elog "To launch server at startup run:"
		elog " rc-update add ${GAME_EXE}-${MOD_DIR}-ded default"
		echo
	fi
}

games-mods_make_ded_exec() {
	cat <<-EOF > "${T}"/${GAME_EXE}-${MOD_DIR}-ded.bin
	#!/bin/sh
	${GAMES_BINDIR}/${DED_EXE} ${SELECT_MOD}${MOD_DIR} ${DED_OPTIONS} \${@}
	EOF
}

games-mods_make_init.d() {
	cat <<EOF > "${T}"/${GAME_EXE}-${MOD_DIR}-ded.init.d
#!/sbin/runscript
$(<${PORTDIR}/header.txt)

depend() {
	need net
}

start() {
	ebegin "Starting ${GAME_TITLE} - ${MOD_NAME} dedicated server"
	start-stop-daemon --start --quiet --background --chuid \\
		${GAMES_USER_DED}:games --env HOME="${GAMES_PREFIX}" --exec \\
		${GAMES_BINDIR}/${GAME_EXE}-${MOD_DIR}-ded \\
		\${${GAME_EXE}_${MOD_DIR}_OPTS}
	eend \$?
}

stop() {
	ebegin "Stopping ${GAME_TITLE} - ${MOD_NAME} dedicated server"
	start-stop-daemon --stop --quiet --exec \\
		${GAMES_BINDIR}/${GAME_EXE}-${MOD_DIR}-ded
	eend \$?
}
EOF
}

games-mods_make_conf.d() {
	if [[ -e ${FILESDIR}/${GAME_EXE}-${MOD_DIR}.conf.d ]]
	then
		cp ${FILESDIR}/${GAME_EXE}-${MOD_DIR}.conf.d \
			"${T}"/${GAME_EXE}-${MOD_DIR}-ded.conf.d
		return 0
	fi
cat <<-EOF > "${T}"/${GAME_EXE}-${MOD_DIR}-ded.conf.d
	$(<${PORTDIR}/header.txt)
	
	# Any extra options you want to pass to the dedicated server
	# ${GAME_EXE}_${MOD_DIR}_OPTS="+set com_hunkmegs 64 +set com_zonemegs 32"
	
	EOF
}
