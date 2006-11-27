# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mercurial.eclass,v 1.3 2006/10/13 23:45:03 agriffis Exp $

# mercurial: Fetch sources from mercurial repositories, similar to cvs.eclass.
# To use this from an ebuild, set EHG_REPO_URI in your ebuild.  Then either
# leave the default src_unpack or call mercurial_src_unpack.

inherit eutils

EXPORT_FUNCTIONS src_unpack

DEPEND="dev-util/mercurial net-misc/rsync"
EHG_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/hg-src"

# This must be set by the ebuild
: ${EHG_REPO_URI:=}              # repository uri

# These can be set by the ebuild but are usually fine as-is
: ${EHG_PROJECT:=$PN}            # dir under EHG_STORE_DIR
: ${EHG_CLONE_CMD:=hg clone}     # clone cmd
: ${EHG_PULL_CMD:=hg pull -u}    # pull cmd

# should be set but blank to prevent using $HOME/.hgrc
export HGRCPATH=

function mercurial_fetch {
	declare repo=${1:-$EHG_REPO_URI}
	repo=${repo%/}  # remove trailing slash
	[[ -n $repo ]] || die "EHG_REPO_URI is empty"
	declare module=${2:-${repo##*/}}

	if [[ ! -d ${EHG_STORE_DIR} ]]; then
		ebegin "create ${EHG_STORE_DIR}"
		addwrite / &&
			mkdir -p "${EHG_STORE_DIR}" &&
			chmod -f g+rw "${EHG_STORE_DIR}" &&
			export SANDBOX_WRITE="${SANDBOX_WRITE%:/}"
		eend $? || die
	fi

	pushd "${EHG_STORE_DIR}" >/dev/null \
		|| die "can't chdir to ${EHG_STORE_DIR}"
	addwrite "$(pwd -P)"

	if [[ ! -d ${EHG_PROJECT}/${module} ]]; then
		# first check out
		ebegin "${EHG_CLONE_CMD} ${repo}"
		mkdir -p "${EHG_PROJECT}" &&
			chmod -f g+rw "${EHG_PROJECT}" &&
			cd "${EHG_PROJECT}" &&
			${EHG_CLONE_CMD} "${repo}" "${module}" &&
			cd "${module}"
		eend $? || die
	else
		# update working copy
		ebegin "${EHG_PULL_CMD} ${repo}"
		cd "${EHG_PROJECT}/${module}" &&
			${EHG_PULL_CMD}
		case $? in
			# hg pull returns status 1 when there were no changes to pull
			1) eend 0 ;;
			*) eend $? || die ;;
		esac
	fi

	# use rsync instead of cp for --exclude
	ebegin "rsync to ${WORKDIR}/${module}"
	mkdir -p "${WORKDIR}/${module}" &&
		rsync -a --delete --exclude=.hg/ . "${WORKDIR}/${module}"
	eend $? || die

	popd >/dev/null
}

function mercurial_src_unpack {
	mercurial_fetch
}
