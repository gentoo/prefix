#!/bin/bash
#
# Preprocessor for 'less'. Used when this environment variable is set:
# LESSOPEN="|lesspipe.sh %s"

# TODO: handle compressed files better

trap 'exit 0' PIPE

guesscompress() {
	case "$1" in
		*.gz)  echo "gunzip -c" ;;
		*.bz2) echo "bunzip2 -c" ;;
		*.Z)   echo "compress -d" ;;
		*)     echo "cat" ;;
	esac
}

lesspipe_file() {
	local out=$(file -L -- "$1")
	case ${out} in
		*" ar archive"*)    lesspipe "$1" ".a" ;;
		*" tar archive"*)   lesspipe "$1" ".tar" ;;
		*" CAB-Installer"*) lesspipe "$1" ".cab" ;;
		*" troff "*)        lesspipe "$1" ".man" ;;
		*" shared object"*) lesspipe "$1" ".so" ;;
		*" Zip archive"*)   lesspipe "$1" ".zip" ;;
		*" LHa"*archive*)   lesspipe "$1" ".lha" ;;
		*" ELF "*)          readelf -a -- "$1" ;;
		*": data")          hexdump -C -- "$1" ;;
		*)                  return 1 ;;
	esac
	return 0
}

lesspipe() {
	local match=$2
	[[ -z ${match} ]] && match=$1

	local DECOMPRESSOR=$(guesscompress "$match")

	case "$match" in

	### Doc files ###
	*.[0-9n]|*.man|\
	*.[0-9n].bz2|*.man.bz2|\
	*.[0-9n].gz|*.man.gz|\
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
	*.tar)                  tar tvvf "$1" ;;
	*.tar.bz2|*.tbz2|*.tbz) tar tjvvf "$1" ;;
	*.tar.gz|*.tgz|*.tar.z) tar tzvvf "$1" ;;

	### Misc archives ###
	*.bz2)        bzip2 -dc -- "$1" ;;
	*.gz|*.z)     gzip -dc -- "$1"  ;;
	*.zip)        unzip -l "$1" ;;
	*.rpm)        rpm -qpivl --changelog -- "$1" ;;
	*.cpi|*.cpio) cpio -itv < "$1" ;;
	*.ace)        unace l "$1" ;;
	*.arc)        arc v "$1" ;;
	*.arj)        unarj l -- "$1" ;;
	*.cab)        cabextract -l -- "$1" ;;
	*.lha|*.lzh)  lha v "$1" ;;
	*.zoo)        zoo -list "$1" ;;
	*.7z)         7z l -- "$1" ;;
	*.a)          ar tv "$1" ;;
	*.so)         readelf -h -d -s -- "$1" ;;
	*.mo|*.gmo)   msgunfmt -- "$1" ;;

	*.rar|.r[0-9][0-9])  unrar l -- "$1" ;;

	*.deb|*.udeb)
		if type -p dpkg > /dev/null ; then
			dpkg --info "$1"
			dpkg --contents "$1"
		else
			ar tv "$1"
			ar p "$1" data.tar.gz | tar tzvvf -
		fi
		;;

	### Media ###
	*.bmp|*.gif|*.jpeg|*.jpg|*.pcd|*.pcx|*.png|*.ppm|*.tga|*.tiff|*.tif)
		identify "$1" || file -L -- "$1"
		;;
	*.avi|*.mpeg|*.mpg|*.mov|*.qt|*.wmv|*.asf|*.rm|*.ram)
		midentify "$1" || file -L -- "$1"
		;;
	*.mp3)        mp3info "$1" || id3info "$1" ;;
	*.ogg)        ogginfo "$1" ;;
	*.flac)       metaflac --list "$1" ;;
	*.iso)        isoinfo -d -i "$1" ; isoinfo -l -i "$1" ;;
	*.bin|*.cue)  cd-info --no-header --no-device-info "$1" ;;

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
			*)                   LESSCOLOR=1;; # default to colorize
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
elif [[ $1 == "-V" ]] ; then
	Id="cvsid"
	cvsid="$Id: lesspipe.sh,v 1.20 2006/11/27 00:33:09 vapier Exp $"
	cat <<-EOF
		$cvsid
		Copyright 2001-2006 Gentoo Foundation
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
		
		Run 'less --help' or 'man less' for more info
	EOF
elif [[ -d $1 ]] ; then
	ls -alF -- "$1"
else
	recur=0
	lesspipe "$1" 2> /dev/null
fi
