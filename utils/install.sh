#!/bin/bash


has_color=false

if which tput >&/dev/null; then
  num_colors=$(tput colors)
  [[ -n "${num_colors}" ]] && [[ num_colors -ge 8 ]] && has_color=true
fi

color_reset='\e[0m'
color_info='\e[1;96m'
color_err='\e[1;91m'
color_bold='\e[0;1m'

if ! $has_color ; then
  color_reset=
  color_info=
  color_err=
  color_bold=
fi

info() {
  echo -e "${color_info}info: ${color_bold}$*${color_reset}"
}

err() {
  >&2 echo -e "${color_err}error: ${color_bold}$*${color_reset}"
}

prefix=/usr
[[ "$(uname -s)" == "Darwin" ]] && prefix=/usr/local

usage() {
  cat <<EOF
usage: $0 [-p <prefix>] [-v]

  -p <prefix>    instalation prefix
                 (default: ${default_prefix})
  -v             verbose
  -h | --help    this message

EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) usage ; exit 0 ;;
    -v) set -x ;;
    -p)
      [[ -z "$2" ]] && \
        err "'-p' requires a prefix to be provided" && exit 1
        prefix=$(realpath -m ${2})
      shift 1
      ;;
    *)
      err "unrecognized option '${1}'"
      exit 1
      ;;
  esac
  shift 1
done

if [[ ! -d "${prefix}" ]] && ! mkdir -p ${prefix} ; then
  err "error creating '${prefix}'"
  exit 1
fi

bindir=${prefix}/bin
sharedir=${prefix}/share
mandir=${sharedir}/man1

mkdir -p ${bindir}
for target in bin/*; do
  script=$(basename ${target})
  if ! cp -f ${target} ${bindir}; then
    err "error: failed copying '${target}' to '${bindir}'" && exit 1
  fi
  chmod 755 ${bindir}/${script}
done

mkdir -p ${sharedir} || exit 1
for target in share/*; do
  shared=$(basename ${target})
  dest=${sharedir}/${shared}

  if ! cp -f ${target} ${dest}; then
    err "error: failed copying '${target}' to '${dest}'" && exit 1
  fi

  sed -i "s,%PREFIX%,${concat_dest}," ${dest}
  if $(grep -q '%PREFIX%' ${dest}); then
    err "error: failed performingg substitutions on '${dest}'" && exit 1
  fi
done

mkdir -p ${mandir} || exit 1
if ! cp -f mw.1 ${mandir}/mw.1; then
  err "error: failed copying 'mw.1' to '${mandir}'" && exit 1
fi

info "install success"
