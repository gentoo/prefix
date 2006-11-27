#
# Documentation is certain to come, but please disregard this eclass for the
# time being, until it has been through more testing.
#

unipatch() {
	# Behavioural environment variables.
	# UNIPATCH_STRICTORDER
	# UNIPATCH_EXCLUDE
	# KPATCH_DIR
	# UNIPATCH_POPTS
	# UNIPATCH_SILENT_DROP

	local myLC_ALL
	local checkfile checkfile_noext checkfile_ext checkfile_patchlvl
	local checkfile_meta checkfile_patchdir checkfile_suffix
	local strictcount i n pipecmd
	local file_list patch_to_process patch_plevel

	# set to a standard locale to ensure sorts are ordered properly.
	myLC_ALL="${LC_ALL}"
	LC_ALL="C"

	# Setup UNIPATCH_POPTS if not set already
	UNIPATCH_POPTS=${UNIPATCH_POPTS:--g0 -s}

	# Set UNIPATCH_SILENT_DROP if not already set
	# Please bare in mind these *cannot* start with an asterisk
	UNIPATCH_SILENT_DROP='000*'

	# We need a temporary directory in which we can stor our patches.
	KPATCH_DIR="${KPATCH_DIR:-${WORKDIR}/patches/}"
	mkdir -p ${KPATCH_DIR}

	# We're gonna need it when doing patches with a predefined patchlevel
	shopt -s extglob

	# lets obtain our patch list
	# any .diff/.patch/compressed file is added, and if neccessary decompressed.
	# any tarred file is unpacked and added
	# anything else is added to the drop pattern
	UNIPATCH_LIST="${@:-${UNIPATCH_LIST}}"

	n=0
	strictcount=0
	for checkfile in ${UNIPATCH_LIST}
	do
		# unset parsed vars first
		unset checkfile_suffix
		unset checkfile_ext
		unset checkfile_patchdir
		checkfile_patchlvl=0

		# did we pass suffix? or a patchlvl?
		for((i=0; i<=${#checkfile}; i++)); do
			case ${checkfile:${i}:1} in
				@)	checkfile_suffix="${checkfile:0:${i}}";;
			 	:)	checkfile_patchlvl="${checkfile:${i}}";;
			esac
		done

		# now lets sane up the checkfile var
		[[ -n ${checkfile_suffix} ]] && checkfile=${checkfile//*@}
		[[ -n ${checkfile_patchlvl} ]] && checkfile=${checkfile//:*}

		# is this file even valid?
		if [[ ! -f ${checkfile} ]]; then
			ewarn "Unable to read file:"
			ewarn "${checkfile}"
			ewarn "Please check this file exists, and its permissions."
			die "unable to locate ${checkfile}"
		fi

		#if we use strict dir, then lets prepend an order
		if [[ -n ${UNIPATCH_STRICTORDER} ]]; then
			checkfile_patchdir=${KPATCH_DIR}/${strictcount}/
			mkdir -p ${checkfile_patchdir}
			strictcount=$((${strictcount} + 1))
		fi

		# Find the directory we are placing this in.
		checkfile_patchdir="${checkfile_patchdir:-${KPATCH_DIR}}"

		# so now lets get finding patches.
		# This is a list of patterns to match, and the resulting extention.
		# you MUST specify the LEAST specific first, if the pattern would match
		# more than one extension. think, .tar.gz vs. .gz
		local testvalues test value temp
		testvalues='*:DROP
					*README:DOC
					*.txt:DOC
					*.gz*:gz
					*.bz*:bz2
					*.tar.bz*:tbz
					*.tbz*:tbz
					*.tar.gz*:tgz
					*.tgz*:tgz
					*.tar:tar
					*.z*:gz
					*.zip*:zip
					*.diff*:diff
					*.patch*:patch'

		# lets see if we qualify for one of the above
		for i in $testvalues; do
			value=${i/*:/}
			test=${i/:*/}
			temp=${checkfile/${test}/${value}}
			if [[ ${temp} == ${value} ]]
			then
				# if we do, then set the extention and the filename, minus ext.
				checkfile_ext="${temp}"
				checkfile_noext="${checkfile/${test:1}/}"
			fi
		done

		# if we specify a suffix, we want to over-ride the above now.
		[[ -n ${checkfile_suffix} ]] && \
			checkfile_ext="${checkfile_suffix}" \
			checkfile_noext="${checkfile/${checkfile_suffix}/}"

		# set metafile
		checkfile_meta="${checkfile_patchdir}/.meta_${checkfile_noext/*\//}"

		# Debug environment
		edebug 3 "Debug environment variables"
		edebug 3 "---------------------------"
		edebug 3 "checkfile=${checkfile}"
		edebug 3 "checkfile_ext=${checkfile_ext}"
		edebug 3 "checkfile_noext=${checkfile_noext}"
		edebug 3 "checkfile_patchdir=${checkfile_patchdir}"
		edebug 3 "checkfile_patchlvl=${checkfile_patchlvl}"
		edebug 3 "checkfile_meta=${checkfile_meta}"
		edebug 3 "checkfile_suffix=${checkfile_suffix}"

		# and setup the appropriate pipecmd for it.
		# the outcome of this should leave the file we want in the patch dir
		case ${checkfile_ext} in
			tbz)	pipecmd="mkdir ${T}/ptmp/;
							 cd ${T}/ptmp/;
							 tar -xjf ${checkfile};
							 find . -type f | sed -e \
							 	's:\./:${checkfile_patchdir}:g' \
							 	> ${checkfile_meta}_files;
							 cp -Rf ${T}/ptmp/* ${checkfile_patchdir};
							 rm -Rf ${T}/ptmp;
							 cd \${OLDPWD}";;
			tgz)	pipecmd="mkdir ${T}/ptmp/;
							 cd ${T}/ptmp/;
							 tar -xzf ${checkfile};
							 find . -type f | sed -e \
							 	's:\./:${checkfile_patchdir}:g' \
							 	> ${checkfile_meta}_files;
							 cp -Rf ${T}/ptmp/* ${checkfile_patchdir};
							 rm -Rf ${T}/ptmp;
							 cd \${OLDPWD}";;
			tar)	pipecmd="mkdir ${T}/ptmp/;
							 cd ${T}/ptmp/;
							 tar -xf ${checkfile};
							 find . -type f | sed -e \
							 	's:\./:${checkfile_patchdir}:g' \
							 	> ${checkfile_meta}_files;
							 cp -Rf ${T}/ptmp/* ${checkfile_patchdir};
							 rm -Rf ${T}/ptmp;
							 cd \${OLDPWD}";;
			zip)	pipecmd="mkdir ${T}/ptmp/;
							 cd ${T}/ptmp/;
							 unzip ${checkfile};
							 find . -type f | sed -e \
							 	's:\./:${checkfile_patchdir}:g' \
							 	> ${checkfile_meta}_files;
							 cp -Rf ${T}/ptmp/* ${checkfile_patchdir};
							 rm -Rf ${T}/ptmp;
							 cd \${OLDPWD}";;
			diff)	pipecmd="cp ${checkfile} ${checkfile_patchdir};
							 echo ${checkfile_patchdir}/${checkfile/*\//} \
							 	> ${checkfile_meta}_files;";;
			patch)	pipecmd="cp ${checkfile} ${checkfile_patchdir};
							 echo ${checkfile_patchdir}/${checkfile/*\//} \
							 	> ${checkfile_meta}_files;";;
			gz)		pipecmd="gzip -dc ${checkfile} > ${T}/gunzip;
						     cp ${T}/gunzip ${checkfile_patchdir}${checkfile_noext/*\//}.diff;
						     rm ${T}/gunzip;
							 echo ${checkfile_patchdir}/${checkfile_noext/*\//}.diff \
							 	> ${checkfile_meta}_files;";;
			bz2)	pipecmd="bzip2 -dc ${checkfile} > ${T}/bunzip;
						     cp ${T}/bunzip ${checkfile_patchdir}${checkfile_noext/*\//}.diff;
						     rm ${T}/bunzip;
							 echo ${checkfile_patchdir}/${checkfile_noext/*\//}.diff \
							 	> ${checkfile_meta}_files;";;
			DROP)	pipecmd="";;
			DOC)	pipecmd="cp ${checkfile} ${checkfile_patchdir}";;
		esac

		# Debug environment
		edebug 3 "pipecmd=${pipecmd}"

		if [[ -z ${pipecmd} ]]; then
			# if we dont know about it, lets drop it and move to the next
			einfo "Unknown Filetype, Ignoring: ${checkfile/*\//}"
		else
			# if we do know about it, prepare it for patching, and
			# populate metadata
			ebegin "Preparing ${checkfile/*\//}"
			eval ${pipecmd}
			eend $?

			echo "PATCHLVL=${checkfile_patchlvl}" >> ${checkfile_meta}
		fi
	done

	# OK so now we got this far, we have everything neatly unpacked.
	# we should probably build up our patch-list.
	edebug 2 "Locating .meta_*_files and building patch list"

	for i in $(find ${KPATCH_DIR} -iname ".meta_*_files")
	do
		file_list=$(sort -n ${i})
		patch_plevel=$(sed -e 's:PATCHLVL=\(.*\):\1:' < ${i/_files/} | uniq)
		edebug 3 "processing: ${i}"
		edebug 3 "file_list=${file_list}"
		edebug 3 "patch_plevel=${patch_plevel}"

		# OK, so now we have trhe list of files to process in this metafile
		# we should process the patch.
		for patch_to_process in ${file_list}; do
			edebug 2 "Processing: ${patch_to_process}"

			# if we pass UNIPATCH_EXCLUDE then we scan through that.
			# if we find a match, we dont bother applying it.
			# This is done here to catch files within tarballs.
			local tempname to_patch=1

			tempname="${patch_to_process/*\//}"
			# Process silent drops
			for x in ${UNIPATCH_SILENT_DROP}; do
				edebug 4 "Checking ${x} against ${tempname} = ${tempname//${x}}"
				if [[ -z ${tempname//${x}} ]]; then
					to_patch=-1
					edebug 2 "Dropping ${tempname} based on ${x} match"
					break;
				fi
			done

			# Process excludes
			for x in ${UNIPATCH_EXCLUDE}; do
				[[ -z ${tempname/${x}*/} ]] && to_patch=0
			done

			if [[ ${to_patch} -eq -1 ]]; then
				# This is something we silently ignore
				:
			elif [[ ${to_patch} -eq 1 ]]; then
				apply_patch ${patch_to_process}
			else
				einfo "Excluding: ${tempname}"
			fi
			unset tempname to_patch
		done
	done

	LC_ALL=${myLC_ALL}
}

apply_patch() {
	local plvl patch_log pmsg
	plvl=${patch_plevel}
	patch_log="${T}/${1/*\//}.log"

	echo "************" > ${patch_log}
	echo "patch log for file:" >> ${patch_log}
	echo "${1}" >> ${patch_log}
	echo "************" >> ${patch_log}
	while [ ${plvl} -lt 5 ]
	do
		edebug 3 "Attempting patch (${1}) with -p${plvl} (${UNIPATCH_POPTS})"

		echo "Attempting:" >> ${patch_log}
		echo "patch ${UNIPATCH_POPTS} -p${plvl} --dry-run -f" >> ${patch_log}
		if (patch ${UNIPATCH_POPTS} -p${plvl} --dry-run -f < ${1}) >> ${patch_log}
		then
			[[ ${VERBOSITY} -ge 1 ]] && pmsg="-p${plvl}"
			[[ ${VERBOSITY} -ge 2 ]] && pmsg="${UNIPATCH_POPTS} ${pmsg}"
			[[ -n ${pmsg} ]] && pmsg=" (${pmsg})"
			echo "**** Applying:" >> ${patch_log}
			ebegin "Applying patch: ${1/*\//}${pmsg}"
			patch ${UNIPATCH_POPTS} -p${plvl} -f < ${1} >> ${patch_log}
			eend $?
			plvl=6
		else
			plvl=$((${plvl} + 1))
		fi
	done
	if [ ${plvl} -eq 5 ]
	then
		ewarn "Unable to apply patch: ${1/*\//}"
		ewarn "Please attach the following patch log when submitting"
		ewarn "a bug."
		ewarn "${patch_log}"
		die "Unable to apply patch: ${1/*\//}"
	fi
}

edebug() {
	local verbosity msg
	verbos=${1}
	shift
	msg=${@}

	VERBOSITY=${VERBOSITY:-0}
	[ ${VERBOSITY} -ge ${verbos} ] && echo "(DD): ${msg}"
}
