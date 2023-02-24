#!/bin/bash -l

# invocation script meant to be launched from cron

LOGFILE="/var/tmp/rsync0.log"

if [[ -f /tmp/rsync-master-busy ]] ; then
	laststart=$(date -r /tmp/rsync-master-busy +%s)
	now=$(date +%s)
	# allow one run to be skipped quietly
	if [[ $((laststart + (40 * 60))) -lt ${now} ]] ; then
		echo "another rsync-master generation process is still busy"
		type pstree > /dev/null && pstree -A -l -p $(head -n1 ${LOGFILE})
		ps -ef | grep '[r]efresh-mirror'
		tail ${LOGFILE}
	else
		exit 0
	fi
	# if the log reports done, kill it as it seems that for some reason
	# it hangs after doing this
	if [[ $(tail -n1 ${LOGFILE}) == *"rsync done" ]] ; then
		pid=$(head -n1 ${LOGFILE})
		if [[ ${pid} -gt 0 ]] ; then
			echo "Killing stray/stuck processes"
			pstree -A -l -c -p ${pid} | grep -o '[0-9]\+' | xargs kill
			rm /tmp/rsync-master-busy
		fi
	fi
else
	mv ${LOGFILE} ${LOGFILE%.log}-prev.log
	cd "$(readlink -f "${BASH_SOURCE[0]%/*}")"
	touch /tmp/rsync-master-busy
	echo $$ > ${LOGFILE}
	echo "starting generation $(date)" >> ${LOGFILE}
	genandpush() {
		./update-rsync-master.sh \
			&& ./push-rsync1.sh
#			&& pushd /export/gentoo/statistics/stats \
#			&& ./gen-timing-rsync0-graph.sh \
#			&& popd > /dev/null
	}
	# get a free filedescriptor in FD
	exec {FD}>/tmp/rsync-master-busy
	( ( (genandpush | tee -a "${LOGFILE}") {FD}>&1 1>&2 2>&${FD} \
	    | tee -a "${LOGFILE}") 2> /dev/null)
	echo "generation done $(date)" >> ${LOGFILE}
	exec {FD}>&-
	rm -f /tmp/rsync-master-busy
fi
