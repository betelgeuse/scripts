#!/bin/bash
number=$(echo ${1} | sed 's/#//' | sed -re 's/[^[:digit:]]+$//')
echo ${number} >> /home/betelgeuse/test/foobar.log
${BROWSER} https://bugs.gentoo.org/${number}
