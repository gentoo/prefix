#!/usr/bin/env bash
#shellcheck disable=SC2016,SC2086
#SC2016: expressions don't expand in single quotes -> purposely in sed
#SC2086: double quote to prevent word splitting -> exactly what we need w/ set

SCRIPTSTARTTIME=$(date +%s)

# get keys for ssh and signing
eval "$(env SHELL=/bin/bash keychain -q --noask --eval)"

BASE_PATH="$(readlink -f "${BASH_SOURCE[0]%/*}")"

PREFIXTREEDIR="${BASE_PATH}/repos/prefix-tree"
GENTOOX86DIR="${BASE_PATH}/repos/gentoo-x86"
DTDDIR="${BASE_PATH}/repos/dtd"
GLSADIR="${BASE_PATH}/repos/glsa"
NEWSDIR="${BASE_PATH}/repos/gentoo-news"
RSYNCDIR="${BASE_PATH}/master-rsync-tree"

#### ---- Portage setup (use local modified copy) ---- ####

PORTAGE_BASE_PATH="${BASE_PATH}/prefix/usr/lib/portage/"
PYTHONPATH="${PORTAGE_BASE_PATH}/pym"
PORTAGE_CONFIGROOT="${BASE_PATH}/misc/config_root"
PORTAGE_DEPCACHEDIR="${BASE_PATH}/depcache"

# for .cvsps and gnupg cache mainly
HOME="${BASE_PATH}/misc"

echo "(init) BASE_PATH=$BASE_PATH"
echo "(init) PORTAGE_BASE_PATH=$PORTAGE_BASE_PATH"
echo "(init) PYTHONPATH=$PYTHONPATH"
echo "(init) PORTAGE_CONFIGROOT=$PORTAGE_CONFIGROOT"
echo "(init) PORTAGE_DEPCACHEDIR=$PORTAGE_DEPCACHEDIR"
echo "(init) PATH=$PATH"

#### ---- egencache settings ---- ####

EGENCACHE_OPTS=(
	"--jobs=$(nproc)"
	"--load-average=$(nproc)"
	"--tolerant"
	"--update-use-local-desc"
)

export PYTHONPATH PORTDIR PORTAGE_BASE_PATH PORTAGE_CONFIGROOT  \
	ROOT PORTAGE_TMPFS FEATURES HOME

#### ---- git mtime helper ---- ####

update_git_tree() {
	git reset -q --hard HEAD
	git clean -dfq
	git pull -q
}

apply_git_mtimes() {
	local from=$1
	local to=$2

	# As of 28-02-2018 we no longer take author or committer time,
	# because both can be garbage (in the future, or terribly in the
	# past).  Instead, we take the starttime of this script, rounded to
	# the minute.  Because all generators should have this set off from
	# cron at the same start-time, this should result in the trees
	# staying in sync.  A scheduled synchronisation should wipe out any
	# differences that may happen.
	local thistime="$(((SCRIPTSTARTTIME / 60) * 60))"

	local ts=0
	local files=()
	{
		git log --pretty=%ct --name-status --reverse "${from}..${to}"
		echo 999  # end marker to trigger the last block to be done
	} | \
	while read -r line ; do
		case "${line}" in
			[0-9][0-9][0-9]*)
				if [[ ${ts} -gt 0 ]] ; then
					[[ ${#files[@]} == 0 ]] || \
						touch -m -d @${thistime} -- "${files[@]}"
				fi
				ts=${line}
				files=()
				;;
			[ACMT]*)
				set -- ${line}
				files+=( "$2" )
				;;
			[R]*)
				set -- ${line}
				files+=( "$3" )
				;;
			[D]*)
				set -- ${line}
				# in case a file is removed, ensure Manifest gets
				# updated by touching a file which should be there
				if [[ $2 == */*/* ]] ; then
					local f=${2}
					# treat anything in files at the package level
					[[ ${f} == */files/* ]] && f=${f%/files/*}/foo
					# if the entire package was removed, touch the
					# category level metadata
					[[ -f ${f%/*}/metadata.xml ]] \
						&& files+=( "${f%/*}"/metadata.xml ) \
						|| files+=( "${f%/*/*}"/metadata.xml )
				fi
				;;
		esac
	done
}

#### ---- section metadata add-ons ---- ####

START=$(date +%s)
GLOBALSTART=${START}

# update DTDs
echo "($(date +"%F %R")) updating DTDs"
pushd "$DTDDIR" || exit 1
fromcommit=$(git log --pretty=format:'%H' -n1)
update_git_tree
tocommit=$(git log --pretty=format:'%H' -n1)
apply_git_mtimes "${fromcommit}" "${tocommit}"
popd || exit 1
# rsync the DTDs
rsync -v --delete -aC "${DTDDIR}" "${RSYNCDIR}"/metadata/ || exit 1
date -R -u > "${RSYNCDIR}"/metadata/dtd/timestamp.chk || exit 1
echo "($(date +"%F %R")) set date to $(< "${RSYNCDIR}"/metadata/dtd/timestamp.chk)"

# update GLSAs
echo "($(date +"%F %R")) updating GLSAs"
pushd "$GLSADIR" || exit 1
fromcommit=$(git log --pretty=format:'%H' -n1)
update_git_tree
tocommit=$(git log --pretty=format:'%H' -n1)
apply_git_mtimes "${fromcommit}" "${tocommit}"
popd || exit 1
# rsync the GLSAs
rsync -v --delete -aC "${GLSADIR}" "${RSYNCDIR}"/metadata/ || exit 1
date -R -u > "${RSYNCDIR}"/metadata/glsa/timestamp.chk || exit 1
echo "($(date +"%F %R")) set date to $(< "${RSYNCDIR}"/metadata/glsa/timestamp.chk)"

# update news
echo "($(date +"%F %R")) updating news"
pushd "$NEWSDIR" || exit 1
fromcommit=$(git log --pretty=format:'%H' -n1)
update_git_tree
tocommit=$(git log --pretty=format:'%H' -n1)
apply_git_mtimes "${fromcommit}" "${tocommit}"
popd || exit 1
mkdir -p "${RSYNCDIR}"/metadata/news
rsync -v -Wa --exclude .git --delete "${NEWSDIR}" "${RSYNCDIR}"/metadata/news/
date -R -u > "${RSYNCDIR}"/metadata/news/timestamp.chk
echo "($(date +"%F %R")) set date to $(< "${RSYNCDIR}"/metadata/news/timestamp.chk)"

# update projects
echo "($(date +"%F %R")) updating projects.xml"
pushd "${RSYNCDIR}"/metadata/ || exit 1
rm -f projects.xml
wget -q "https://api.gentoo.org/metastructure/projects.xml" || exit 1
popd || exit 1
echo "($(date +"%F %R")) projects.xml updated"

STOP=$(date +%s)
TIME_METADATA=$((STOP - START))

#### ---- END section metadata add-ons END ---- ####

START=$(date +%s)

echo "($(date +"%F %R")) updating the gx86 tree"
pushd "${GENTOOX86DIR}" || exit 1
fromcommit=$(git log --pretty=format:'%H' -n1)
update_git_tree
tocommit=$(git log --pretty=format:'%H' -n1)
gx86tscommit=$(git log --pretty=format:'%H %ct %cI' -n1 "${tocommit}")
apply_git_mtimes "${fromcommit}" "${tocommit}"
popd || exit 1
rsync -v \
	--exclude=metadata/cache \
	--exclude=metadata/dtd \
	--exclude=metadata/glsa \
	--exclude=metadata/projects.xml \
	--exclude=metadata/md5-cache \
	--exclude=metadata/news \
	--exclude=scripts \
	--exclude=.#* \
	--delete -aC "${GENTOOX86DIR}"/ "${RSYNCDIR}"/
echo "($(date +"%F %R")) entire gx86 tree copied"

STOP=$(date +%s)
TIME_CVSGX86=$((STOP - START))

START=$(date +%s)

# update the prefix-tree image
echo "($(date +"%F %R")) updating Prefix tree (Git image)"
pushd "$PREFIXTREEDIR" || exit 1
fromcommit=$(git log --pretty=format:'%H' -n1)
update_git_tree
tocommit=$(git log --pretty=format:'%H' -n1)
pfxtscommit=$(git log --pretty=format:'%H %ct %cI' -n1 "${tocommit}")
apply_git_mtimes "${fromcommit}" "${tocommit}"
echo "($(date +"%F %R")) git image updated"

# rsync the SVN image to the rsync master
echo "($(date +"%F %R")) rsync Prefix tree to rsync-master"
for entry in scripts *-*/* ; do
	# copy it over
	[[ -e ${RSYNCDIR}/${entry} ]] || mkdir -p "${RSYNCDIR}/${entry}"
	rsync -v --delete -aC "${PREFIXTREEDIR}/${entry}"/ "${RSYNCDIR}/${entry}"/
done

# we excluded the eclasses above, because we "overlay" them from gx86
# with the Prefix ones (inside the directory, so no --delete)
rsync -v -aC "${PREFIXTREEDIR}"/eclass/ "${RSYNCDIR}"/eclass/ || exit 1
popd || exit 1
echo "($(date +"%F %R")) Prefix tree rsynced"

STOP=$(date +%s)
TIME_SVNPREFIX=$((STOP - START))


# define repo_name, can't use gx86's name as we're different
echo "($(date +"%F %R")) setting repo_name and making the prefix profiles development ones (iso exp)"
echo "gentoo_prefix" > "${RSYNCDIR}"/profiles/repo_name
touch -r "${GENTOOX86DIR}"/profiles/repo_name "${RSYNCDIR}"/profiles/repo_name
# reset Prefix profiles to dev status
sed -i -e '/prefix/s/exp/dev/' "${RSYNCDIR}"/profiles/profiles.desc
touch -r "${GENTOOX86DIR}"/profiles/profiles.desc "${RSYNCDIR}"/profiles/profiles.desc
echo "($(date +"%F %R")) set up repo $(< "${RSYNCDIR}"/profiles/repo_name)"


START=$(date +%s)

# generate the metadata
echo "($(date +"%F %R")) generating metadata"
dolog() {
	echo "$*"
	"$@"
}
dolog "${PORTAGE_BASE_PATH}/bin/egencache" --update --rsync \
	--config-root="${PORTAGE_CONFIGROOT}" \
	--cache-dir="${PORTAGE_DEPCACHEDIR}" \
	--repo=gentoo_prefix \
	--repositories-configuration='
[DEFAULT]
main-repo = gentoo_prefix

[gentoo_prefix]
location = '"${RSYNCDIR}"'
sync-type = rsync
sync-uri = rsync://dont-sync
auto-sync = no
' \
	"${EGENCACHE_OPTS[@]}" \
	|| exit 5

STOP=$(date +%s)
TIME_EGENCACHE=$((STOP - START))

date -u > "${RSYNCDIR}"/metadata/timestamp
date -u '+%s %c %Z' > "${RSYNCDIR}"/metadata/timestamp.x
date -R -u > "${RSYNCDIR}"/metadata/timestamp.chk
echo "${gx86tscommit}" > "${RSYNCDIR}"/metadata/timestamp.commit
echo "${pfxtscommit}" > "${RSYNCDIR}"/metadata/timestamp.commit.prefix-tree
echo "($(date +"%F %R")) set date to $(<"${RSYNCDIR}"/metadata/timestamp.chk)"


# safety for all
chmod -R u-s,g-s "${RSYNCDIR}"/metadata

STOP=$(date +%s)
TIME_TOTAL=$((STOP - GLOBALSTART))

START=$(date +%s)

echo "($(date +"%F %R")) signing Manifest"

# we will generate thick manifests, so ensure Portage knows that.
# add a "gentoo" alias for compatibility, bug #911543.
sed -e '/^thin-manifests/s/true/false/' \
    -e '$arepo-name = gentoo_prefix\naliases = gentoo' \
    -i "${RSYNCDIR}"/metadata/layout.conf

# generate Thick Manifests
# Signing is done with our snapshot signing key, and only on the top
# level Manifest, for it covers indirectly the entire tree
# remember, HOME is set to misc/ so .gnupg keychain lives there
qmanifest -g -p -s "0xC6317B3C" "${RSYNCDIR}" \
	< "${BASE_PATH}"/autosigner.pwd || \
	echo "Manifest generation and/or signing failed!" >> /dev/stderr

echo "($(date +"%F %R")) Manifest signed"

STOP=$(date +%s)
TIME_MANISIGN=$((STOP - START))

# feed timings to graphite
prefix="gentoo.rsync-generation.$(hostname -s)"
{
	echo "${prefix}.pull-metadata ${TIME_METADATA} ${GLOBALSTART}"
	echo "${prefix}.pull-overlay ${TIME_SVNPREFIX} ${GLOBALSTART}"
	echo "${prefix}.pull-gx86 ${TIME_CVSGX86} ${GLOBALSTART}"
	echo "${prefix}.egencache ${TIME_EGENCACHE} ${GLOBALSTART}"
	echo "${prefix}.wallclock ${TIME_TOTAL} ${GLOBALSTART}"
	echo "${prefix}.signing ${TIME_MANISIGN} ${GLOBALSTART}"
} | nc -q 0 localhost 3002
