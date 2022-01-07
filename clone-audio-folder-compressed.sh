#!/bin/bash

# cfr. https://stackoverflow.com/a/3232082
confirm() {
  # call with a prompt string or use a default
  read -r -p "${1:-Are you sure?} [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) 
      true
    ;;
    *)
      false
    ;;
  esac
}

# only return lines that are EXCLUSIVELY found in the first file
onlyleft() {
  # cfr. https://stackoverflow.com/a/53426391
  # cat includes.txt excludes.txt excludes.txt | sort | uniq --unique
  cat $1 $2 $2 | sort | uniq -u
}

# maybe source folders can also be selected interactively with a program called dialog:
# https://www.bytebang.at/Blog/Select+files+with+a+dialog+witin+a+BASH+script
# or maybe I should use whiptail? (should be like a drop-in replacement)


# TODO: check argument validity and show a help message when they are incorrect
SRCDIR="$1"
DSTDIR="$2"

# aac or ogg (or mayeb some others like wma later on)
TYPE="$3"

TMP_SRCFILES=/tmp/srcfiles
TMP_DSTFILES=/tmp/dstfiles
TMP_SRCFILES_NOEXT=/tmp/srcfilesnoext
TMP_DSTFILES_NOEXT=/tmp/dstfilesnoext

TMP_ONLYINSRCFILES=/tmp/onlyinsrcfiles

echo "Will try to make a 'clone' of all the audio files under $SRCDIR into $DSTDIR"
confirm "Do you want to continue?" || exit 0

# confirm "[WATCH OUT] Do you want to remove all the files in $DSTDIR first to start with a clean slate???" && rm -r "${DSTDIR}/*"
( cd "${SRCDIR}" && find . -type f -regex '.*\(flac\|wma\|ape\|wav\)' ) | sort > "${TMP_SRCFILES}"
head "${TMP_SRCFILES}"

( cd "${DSTDIR}" && find . -type f -regex '.*\(flac\|wma\|ape\|wav\)' ) | sort > "${TMP_DSTFILES}"


# cat "${TMP_SRCFILES}" | while read F; do echo "${F%.*}"; done > "${TMP_SRCFILES_NOEXT}"
# cat "${TMP_DSTFILES}" | while read F; do echo "${F%.*}"; done > "${TMP_DSTFILES_NOEXT}"

# onlyleft "${TMP_SRCFILES_NOEXT}" "${TMP_DSTFILES_NOEXT}" > "${TMP_ONLYINSRCFILES}"

# confirm "Print all the files that will be transcoded?" && more "${TMP_ONLYINSRCFILES}"


confirm "Start transcoding?" || exit 1

echo "Let's go..."

(
  # only separate on new lines
  IFS=$'\n'
  # cat "${TMP_SRCFILES}" |
  while read -u 10 SRCFILE; do
    echo
    echo "$SRCFILE"
    echo "=========================================================================================="
    FNOEXT="${SRCFILE%.*}"
    FPATH="${SRCFILE%/*}"
    FCONVERTED="${FNOEXT}.${TYPE}"
    DSTPATH="${DSTDIR}/${FCONVERTED}"

    if [ ! -e "${DSTPATH}" ]; then
      sleep 3
      # echo
      echo "---> Start converting [${DSTPATH}] <---"
      echo

      case "${TYPE}" in
        aac)
          # FOR AAC
          #########
          # libfdk_aac should be highest quality codec but not available on synology
          # libfaac might be lower quality but the default aac is said to be experimental on the current version on diskstation
          # -vn should remove the video channel with cover art that some flacs contain apparently
          mkdir -p "${DSTDIR}/${FPATH}" && ffmpeg -i "${SRCDIR}/${SRCFILE}" -ab 160000 -acodec aac -vn "${DSTPATH}"
        ;;
        ogg)
          mkdir -p "${DSTDIR}/${FPATH}" && ffmpeg -i "${SRCDIR}/${SRCFILE}" -ab 160000 -vn "${DSTPATH}"
        ;;
      esac

      # remove the file if the previous command didn't exit properly??
      # $? || rm "${DSTDIR}/${FNOEXT}.m4a"
    else
      >&2 echo
      >&2 echo "----> Skipping [${DSTPATH}] because it already exists... <----"
      >&2 echo
    fi
  done 10<"${TMP_SRCFILES}"
)

