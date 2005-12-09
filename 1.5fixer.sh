#!/bin/bash
if [[ ! -x /usr/bin/qfile ]]; then
	echo "You need to emerge portage-utils."
	exit 1
fi

fixer=$(mktemp /tmp/fixer.XXXXXX)

wget http://gentooexperimental.org/svn/java/javatoolkit/src/bsfix/class-version-verify.py \
	-O ${fixer}

chmod +x ${fixer}

pkgs=""
for jar in $(${fixer} -t 1.4 /usr/share/*/lib/*.jar -f); do 
	pkgs="${pkgs} =$(qfile -C -q -v ${jar})"
done

if [[ -z "${pkgs}" ]]; then
	echo "No broken files found."
else
	emerge -1 ${pkgs}
fi

rm ${fixer}
