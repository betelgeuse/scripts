#!/bin/sh

# Author: Petteri Räty <betelgeuse@gentoo.org>

# This script is potentially very dangerous
# to your system so use this at your own
# risk.

# Placed in the public domain

backup=$(mktemp /tmp/worldbackupXXXXXX)
items=$(mktemp /tmp/javapackagesXXXXXX)

cp /var/lib/portage/world ${backup}

equery depends virtual/jre > ${items}
sed -i -e "s/^/=/" ${items}

${EDITOR} ${items}

cat ${items} | xargs emerge -C "${@}" 
cat ${items} | xargs emerge -1 "${@}"

cp ${backup} /var/lib/portage/world

