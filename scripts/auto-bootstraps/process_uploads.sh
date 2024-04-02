#!/usr/bin/env bash
#shellcheck disable=SC1091

UPLOADDIR="./uploads"
RESULTSDIR="./results"

if [[ -x ${BASH_SOURCE[0]%/*}/process_uploads_local.sh ]] ; then
	source "${BASH_SOURCE[0]%/*}"/process_uploads_local.sh
fi

if [[ $(type -t process_file) != function ]] ; then
	process_file() {
		return
	}
fi

didsomething=
for d in "${UPLOADDIR}"/* ; do
	if [[ ! -d "${d}" ]] ; then
		rm -f "${d}"
		continue
	fi

	# structure: randomid/chost/date
	# chost/date should be the only thing in randomid/ check this
	set -- "${d}"/*/*
	if [[ $# -ne 1 ]] || [[ ! -d "$1" ]] ; then
		rm -Rf "${d}"
		continue
	fi

	dir=${1#"${d}"/}
	# skip this thing from auto-processing if it is new platform
	[[ -d ${RESULTSDIR}/${dir%/*} ]] || continue
	# skip this thing if it already exists
	[[ -d ${RESULTSDIR}/${dir} ]] && continue
	# skip this thing if it isn't complete yet
	[[ -d ${d}/${dir}/push-complete ]] || continue

	# only copy over what we expect, so we leave any uploaded cruft
	# behind
	mkdir "${RESULTSDIR}/${dir}"
	for f in \
		distfiles \
		stage{1,2,3}.log \
		.stage{1,2,3}-finished \
		bootstrap-prefix.sh \
		emerge.log \
		startprefix \
		elapsedtime \
		make.conf ;
	do
		if [[ -e "${d}/${dir}/${f}" ]] ; then
			mv "${d}/${dir}/${f}" "${RESULTSDIR}/${dir}"/
			process_file "${RESULTSDIR}/${dir}/${f}"
		fi
	done
	if [[ -e "${d}/${dir}/portage" ]] ; then
		for pkg in "${d}/${dir}/portage"/*/* ; do
			[[ -e ${pkg} ]] || continue
			w=${pkg#"${d}"/}
			mkdir -p "${RESULTSDIR}/${w}"
			[[ -e "${pkg}"/build-info ]] && \
				mv "${pkg}"/build-info "${RESULTSDIR}/${w}"/
			if [[ -e "${pkg}"/temp ]] ; then
				mv "${pkg}"/temp "${RESULTSDIR}/${w}"/
				process_file "${RESULTSDIR}/${w}"/temp
			fi
		done
	fi
	chmod -R o+rX,go-w "${RESULTSDIR}/${dir}"
	rm -Rf "${d}"

	[[ -e "${RESULTSDIR}/${dir}"/distfiles ]] && \
		./update_distfiles.py "${RESULTSDIR}/${dir}"/distfiles > /dev/null
	didsomething=1
done
[[ -n ${didsomething} ]] && ./analyse_result.py > /dev/null
