#!/usr/bin/env bash

# get keys for ssh and signing
eval $(env SHELL=/bin/bash keychain -q --noask --eval)

BASE_PATH="$(readlink -f "${BASH_SOURCE[0]%/*}")"

HGDIR="${BASE_PATH}/repos/prefix-tree"
CVSDIR="${BASE_PATH}/repos/gentoo-x86"
DTDDIR="${BASE_PATH}/repos/dtd"
GLSADIR="${BASE_PATH}/repos/glsa"
NEWSDIR="${BASE_PATH}/repos/gentoo-news"
RSYNCDIR="${BASE_PATH}/master-rsync-tree"

#### ---- Portage setup (use local modified copy) ---- ####

PORTAGE_BASE_PATH="${BASE_PATH}/prefix/usr/lib/portage/"
PYTHONPATH="${PORTAGE_BASE_PATH}/pym"
PORTAGE_CONFIGROOT="${BASE_PATH}/misc/config_root"
PORTAGE_DEPCACHEDIR="${BASE_PATH}/depcache"
MANIFEST_CACHE="${BASE_PATH}/manifests"

# for .cvsps and gnupg cache mainly
HOME="${BASE_PATH}/misc"

echo "(init) BASE_PATH=$BASE_PATH"
echo "(init) PORTAGE_BASE_PATH=$PORTAGE_BASE_PATH"
echo "(init) PYTHONPATH=$PYTHONPATH"
echo "(init) PORTAGE_CONFIGROOT=$PORTAGE_CONFIGROOT"
echo "(init) PORTAGE_DEPCACHEDIR=$PORTAGE_DEPCACHEDIR"
echo "(init) PATH=$PATH"

#### ---- egencache settings ---- ####

EGENCACHE_OPTS="--jobs=4 --load-average=3 --tolerant --update-use-local-desc"

export PYTHONPATH PORTDIR PORTAGE_BASE_PATH PORTAGE_CONFIGROOT  \
	ROOT PORTAGE_TMPFS FEATURES HOME

#### ---- section metadata add-ons ---- ####

START=$(date +%s)
GLOBALSTART=${START}

# update DTDs
echo "($(date +"%F %R")) updating DTDs"
pushd "$DTDDIR" || exit 1
git pull -q
popd || exit 1
# rsync the DTDs
rsync -v --delete -aC "${DTDDIR}" "${RSYNCDIR}"/metadata/ || exit 1
date -R -u > "${RSYNCDIR}"/metadata/dtd/timestamp.chk || exit 1
echo "($(date +"%F %R")) set date to $(< "${RSYNCDIR}"/metadata/dtd/timestamp.chk)"

# update GLSAs
echo "($(date +"%F %R")) updating GLSAs"
pushd "$GLSADIR" || exit 1
git pull -q
popd || exit 1
# rsync the GLSAs
rsync -v --delete -aC "${GLSADIR}" "${RSYNCDIR}"/metadata/ || exit 1
date -R -u > "${RSYNCDIR}"/metadata/glsa/timestamp.chk || exit 1
echo "($(date +"%F %R")) set date to $(< "${RSYNCDIR}"/metadata/glsa/timestamp.chk)"

# update news
echo "($(date +"%F %R")) updating news"
pushd "$NEWSDIR" || exit 1
git pull -q
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
echo "($(date +"%F %R")) projectss.xml updated"

STOP=$(date +%s)
TIME_METADATA=$((STOP - START))

#### ---- END section metadata add-ons END ---- ####

START=$(date +%s)

echo "($(date +"%F %R")) updating the gx86 tree"
pushd "${CVSDIR}" || exit 1
git pull -q
popd || exit 1
rsync -v \
	--exclude=metadata/cache \
	--exclude=metadata/dtd \
	--exclude=metadata/glsa \
	--exclude=metadata/herds.xml \
	--exclude=metadata/md5-cache \
	--exclude=metadata/news \
	--exclude=scripts \
	--exclude=.#* \
	--delete -aC "${CVSDIR}"/ "${RSYNCDIR}"/
echo "($(date +"%F %R")) entire CVS tree copied"

STOP=$(date +%s)
TIME_CVSGX86=$((STOP - START))

START=$(date +%s)

# update the Mercurial image
echo "($(date +"%F %R")) updating Prefix tree (Git image)"
pushd "$HGDIR" || exit 1
git pull -q || echo "Failed to pull!"
echo "($(date +"%F %R")) Mercurial image updated"

# rsync the SVN image to the rsync master
echo "($(date +"%F %R")) rsync Mercurial image to rsync-master"
for entry in scripts *-*/* ; do
	# copy it over
	[[ -e ${RSYNCDIR}/${entry} ]] || mkdir -p "${RSYNCDIR}"/${entry}
	rsync -v --delete -aC "${HGDIR}"/${entry}/ "${RSYNCDIR}"/${entry}/
done

# we excluded the eclasses above, because we "overlay" them from gx86
# with the Prefix ones (inside the directory, so no --delete)
rsync -v -aC "${HGDIR}"/eclass/ "${RSYNCDIR}"/eclass/ || exit 1
popd || exit 1
echo "($(date +"%F %R")) Mercurial image rsynced"

STOP=$(date +%s)
TIME_SVNPREFIX=$((STOP - START))

START=$(date +%s)

echo "($(date +"%F %R")) signing unsigned Manifests"

# generate Thick Manifests
${BASE_PATH}/hashgen ${RSYNCDIR}

# We store signed Manifests in a "cache", so we don't have to
# generate them all-over all the time.  Generation needs to take place
# if:
# 1. the original Manifest isn't signed
# 2. we don't have one generated file
# 3. the Manifest modification time is newer than our generated file
# Signing is done with our snapshot signing key
sign_manifest() {
	local pkg=$1
	local mc=${pkg//\//_}.manifest
	[[ -z ${pkg} ]] && return 1

	if [[ ! -f ${MANIFEST_CACHE}/${mc} || ${RSYNCDIR}/${pkg}/Manifest -nt ${MANIFEST_CACHE}/${mc} ]] ; then
		mkdir -p "${MANIFEST_CACHE}"

		echo "Signing Manifest for ${pkg}"
		cat "${RSYNCDIR}/${pkg}"/Manifest > "${MANIFEST_CACHE}"/${mc}
		# remember, HOME is set to misc/ so .gnupg keychain lives there
		gpg --batch --no-tty --passphrase-fd 0 --default-key C6317B3C \
			--pinentry-mode loopback \
			--sign --clearsign --digest-algo SHA256 \
			--yes "${MANIFEST_CACHE}"/${mc} \
			< "${BASE_PATH}"/autosigner.pwd >& /dev/null
		if [[ -f ${MANIFEST_CACHE}/${mc}.asc ]] ; then
			touch -r "${MANIFEST_CACHE}"/${mc}{,.asc}
			mv "${MANIFEST_CACHE}"/${mc}{.asc,}
		else
			rm "${MANIFEST_CACHE}"/${mc}
			echo "signing failed!" >> /dev/stderr
			return 0
		fi
	fi

	cp -a "${MANIFEST_CACHE}"/${mc} "${RSYNCDIR}/${pkg}"/Manifest

	return 0
}

for entry in "${RSYNCDIR}"/*/* ; do
	[[ ! -f "${entry}"/Manifest ]] && continue
	entry=${entry#${RSYNCDIR}/}
	sign_manifest "${entry}"
done

echo "($(date +"%F %R")) unsigned Manifests signed"

STOP=$(date +%s)
TIME_MANISIGN=$((STOP - START))


# define repo_name, can't use gx86's name as we're different
echo "($(date +"%F %R")) setting repo_name and making the prefix profiles development ones (iso exp)"
echo "gentoo_prefix" > "${RSYNCDIR}"/profiles/repo_name
touch -r "${CVSDIR}"/profiles/repo_name "${RSYNCDIR}"/profiles/repo_name
# reset Prefix profiles to dev status
sed -i -e '/prefix/s/exp/dev/' "${RSYNCDIR}"/profiles/profiles.desc
touch -r "${CVSDIR}"/profiles/profiles.desc "${RSYNCDIR}"/profiles/profiles.desc
echo "($(date +"%F %R")) set up repo $(< "${RSYNCDIR}"/profiles/repo_name)"


START=$(date +%s)

# generate the metadata
echo "($(date +"%F %R")) generating metadata"
dolog() {
	echo $*
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
	${EGENCACHE_OPTS} \
	|| exit 5

STOP=$(date +%s)
TIME_EGENCACHE=$((STOP - START))

date -u > "${RSYNCDIR}"/metadata/timestamp
date -u '+%s %c %Z' > "${RSYNCDIR}"/metadata/timestamp.x
date -R -u > "${RSYNCDIR}"/metadata/timestamp.chk
echo "($(date +"%F %R")) set date to $(<"${RSYNCDIR}"/metadata/timestamp.chk)"


# safety for all
chmod -R u-s,g-s "${RSYNCDIR}"/metadata

STOP=$(date +%s)
TIME_TOTAL=$((STOP - GLOBALSTART))

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
