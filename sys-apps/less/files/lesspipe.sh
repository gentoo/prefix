#!/bin/bash
#
# Preprocessor for 'less'. Used when this environment variable is set:
# LESSOPEN="|lesspipe.sh %s"

# TODO: handle compressed files better

trap 'exit 0' PIPE

guesscompress() {
	case "$1" in
		*.gz|*.z) echo "gunzip -c" ;;
		*.bz2)    echo "bunzip2 -c" ;;
		*.lz)     echo "lzip -c" ;;
		*.lzma)   echo "unlzma -c" ;;
		*.xz)     echo "xzdec" ;;
		*)        echo "cat" ;;
	esac
}

lesspipe_file() {
	local out=$(file -L -- "$1")
	local suffix
	case ${out} in
		*" 7-zip archive"*) suffix="7z";;
		*" ar archive"*)    suffix="a";;
		*" CAB-Installer"*) suffix="cab";;
		*" cpio archive"*)  suffix="cpio";;
		*" ELF "*)          suffix="elf";;
		*" LHa"*archive*)   suffix="lha";;
		*" troff "*)        suffix="man";;
		*" script text"*)   suffix="sh";;
		*" shared object"*) suffix="so";;
		*" tar archive"*)   suffix="tar";;
		*" Zip archive"*)   suffix="zip";;
		*": data")          hexdump -C -- "$1"; return 0;;
		*)                  return 1;;
	esac
	lesspipe "$1" ".${suffix}"
	return 0
}

lesspipe() {
	local match=$2
	[[ -z ${match} ]] && match=$1

	local DECOMPRESSOR=$(guesscompress "$match")

	# User filters
	if [[ -x ~/.lessfilter ]] ; then
		~/.lessfilter "$1" && exit 0
	fi

	local ignore
	for ignore in ${LESSIGNORE} ; do
		[[ ${match} == *.${ignore} ]] && exit 0
	done

	case "$match" in

	### Doc files ###
	*.[0-9n]|*.man|\
	*.[0-9n].bz2|*.man.bz2|\
	*.[0-9n].gz|*.man.gz|\
	*.[0-9n].lzma|*.man.lzma|\
	*.[0-9][a-z].gz|*.[0-9][a-z].gz)
		local out=$(${DECOMPRESSOR} -- "$1" | file -)
		case ${out} in
			*troff*)
				# Need to make sure we pass path to man or it will try
				# to locate "$1" in the man search paths
				if [[ $1 == /* ]] ; then
					man -- "$1"
				else
					man -- "./$1"
				fi
				;;
			*text*)
				${DECOMPRESSOR} -- "$1"
				;;
			*)
				# We could have matched a library (libc.so.6), so let
				# `file` figure out what the hell this thing is
				lesspipe_file "$1"
				;;
		esac
		;;
	*.dvi)      dvi2tty "$1" ;;
	*.ps|*.pdf) ps2ascii "$1" || pstotext "$1" || pdftotext "$1" ;;
	*.doc)      antiword "$1" || catdoc "$1" ;;
	*.rtf)      unrtf --nopict --text "$1" ;;
	*.conf|*.txt|*.log) ;; # force less to work on these directly #150256

	### URLs ###
	ftp://*|http://*|*.htm|*.html)
		for b in links2 links lynx ; do
			${b} -dump "$1" && exit 0
		done
		html2text -style pretty "$1"
		;;

	### Tar files ###
	*.tar|\
	*.tar.bz2|*.tbz2|*.tbz|\
	*.tar.gz|*.tgz|*.tar.z|\
	*.tar.lz|*.tar.tlz|\
	*.tar.lzma|*.tar.xz)
		${DECOMPRESSOR} -- "$1" | tar tvvf -;;

	### Misc archives ###
	*.bz2|\
	*.gz|*.z|\
	*.lz|\
	*.lzma|*.xz)  ${DECOMPRESSOR} -- "$1" ;;
	*.rpm)        rpm -qpivl --changelog -- "$1" ;;
	*.cpi|*.cpio) cpio -itv < "$1" ;;
	*.ace)        unace l "$1" ;;
	*.arc)        arc v "$1" ;;
	*.arj)        unarj l -- "$1" ;;
	*.cab)        cabextract -l -- "$1" ;;
	*.lha|*.lzh)  lha v "$1" ;;
	*.zoo)        zoo -list "$1" || unzoo -l "$1" ;;
	*.7z)         7z l -- "$1" || 7za l -- "$1" ;;
	*.a)          ar tv "$1" ;;
	*.elf)        readelf -a -- "$1" ;;
	*.so)         readelf -h -d -s -- "$1" ;;
	*.mo|*.gmo)   msgunfmt -- "$1" ;;

	*.rar|.r[0-9][0-9])  unrar l -- "$1" ;;

	*.jar|*.war|*.ear|*.xpi|*.zip)
		unzip -v "$1" || miniunzip -l "$1" || miniunz -l "$1" || zipinfo -v "$1"
		;;

	*.deb|*.udeb)
		if type -P dpkg > /dev/null ; then
			dpkg --info "$1"
			dpkg --contents "$1"
		else
			ar tv "$1"
			ar p "$1" data.tar.gz | tar tzvvf -
		fi
		;;

	### Media ###
	*.bmp|*.gif|*.jpeg|*.jpg|*.ico|*.pcd|*.pcx|*.png|*.ppm|*.tga|*.tiff|*.tif)
		identify "$1" || file -L -- "$1"
		;;
	*.avi|*.mpeg|*.mpg|*.mov|*.qt|*.wmv|*.asf|*.rm|*.ram)
		midentify "$1" || file -L -- "$1"
		;;
	*.mp3)        mp3info "$1" || id3info "$1" ;;
	*.ogg)        ogginfo "$1" ;;
	*.flac)       metaflac --list "$1" ;;
	*.torrent)    torrentinfo-console "$1" || ctorrent -x "$1" ;;
	*.bin|*.cue|*.raw)
		# not all .bin/.raw files are cd images, so fall back to hexdump
		cd-info --no-header --no-device-info "$1" || lesspipe_file "$1"
		;;
	*.iso)
		iso_info=$(isoinfo -d -i "$1")
		echo "${iso_info}"
		# Joliet output overrides Rock Ridge, so prefer the better Rock
		case ${iso_info} in
			*$'\n'"Rock Ridge"*) iso_opts="-R";;
			*$'\n'"Joliet"*)     iso_opts="-J";;
			*)                   iso_opts="";;
		esac
		isoinfo -l ${iso_opts} -i "$1"
		;;

	### Source code ###
	*.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
	*.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
	*.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
	*.diff|*.patch|*.py|*.rb|*.sql|*.ebuild|*.eclass)

		# Allow people to flip color off if they dont want it
		case ${LESSCOLOR} in
			always)              LESSCOLOR=2;;
			[yY][eE][sS]|1|true) LESSCOLOR=1;;
			[nN][oO]|0|false)    LESSCOLOR=0;;
			*)                   LESSCOLOR=0;; # default to no color #188835
		esac
		[[ ${LESSCOLORIZER+set} != "set" ]] && LESSCOLORIZER=code2color
		if [[ ${LESSCOLOR} == "0" ]] || [[ -z ${LESSCOLORIZER} ]] ; then
			# let less itself handle these files
			exit 0
		fi

		# Only colorize if user forces it ...
		if [[ ${LESSCOLOR} == "2" ]]; then
			${LESSCOLORIZER} "$1"
			exit 0
		fi
		# ... or we know less will handle raw codes
		for opt in ${LESS} ; do
			if [[ ${opt} == "-r" || ${opt} == "-R" ]] ; then
				${LESSCOLORIZER} "$1"
				break
			fi
		done
		;;

# May not be such a good idea :)
#	### Device nodes ###
#	/dev/[hs]d[a-z]*)
#		fdisk -l "${1:0:8}"
#		[[ $1 == *hd* ]] && hdparm -I "${1:0:8}"
#		;;

	### Everything else ###
	*)
		# Sanity check
		[[ ${recur} == 2 ]] && exit 0

		# Maybe we didn't match due to case issues ...
		if [[ ${recur} == 0 ]] ; then
			recur=1
			lesspipe "$1" "$(echo $1 | tr '[:upper:]' '[:lower:]')"

		# Maybe we didn't match because the file is named weird ...
		else
			recur=2
			lesspipe_file "$1"
		fi

		exit 0
		;;
	esac
}

if [[ -z $1 ]] ; then
	echo "Usage: lesspipe.sh <file>"
elif [[ $1 == "-V" || $1 == "--version" ]] ; then
	Id="cvsid"
	cvsid="$Id: lesspipe.sh,v 1.32 2009/02/02 19:44:13 vapier Exp $"
	cat <<-EOF
		$cvsid
		Copyright 2001-2009 Gentoo Foundation
		Mike Frysinger <vapier@gentoo.org>
		     (with plenty of ideas stolen from other projects/distros)


	EOF
	less -V
elif [[ $1 == "-h" || $1 == "--help" ]] ; then
	cat <<-EOF
		lesspipe.sh: preproccess files before sending them to less

		Usage: lesspipe.sh <file>

		lesspipe.sh specific settings:
		  LESSCOLOR env     - toggle colorizing of output
		  LESSCOLORIZER env - program used to colorize output (default: code2color)
		  LESSIGNORE        - list of extensions to ignore (don't do anything fancy)

		You can create per-user filters as well by creating the executable file:
		  ~/.lessfilter
		One argument is passed to it: the file to display.

		To use lesspipe.sh, simply add to your environment:
		  export LESSOPEN="|lesspipe.sh %s"

		Run 'less --help' or 'man less' for more info
	EOF
elif [[ -d $1 ]] ; then
	ls -alF -- "$1"
else
	recur=0
	lesspipe "$1" 2> /dev/null
fi
