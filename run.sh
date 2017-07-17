#!/bin/bash
#
#

php_path="/usr/local/php-5.4.25"
check_file="${php_path}/etc/check"
php_fpm=${php_path}/sbin/php-fpm
php_pid=${php_path}/var/run/php-fpm.pid

Chk_File () {
    old_cksum="`cksum ${check_file}`"
    inotifywait=/usr/local/inotify/bin/inotifywait
    ${inotifywait} -e modify,move,create,delete \
        -mr --timefmt '%d/%m/%y %H:%M' --format '%T' \
        "${check_file}" | while read date time; do
    new_cksum="`cksum ${check_file}`"
        if [ "${new_cksum}" != "${old_cksum}" ]; then
            old_cksum="${new_cksum}"
            kill -SIGUSR2 $(cat ${php_pid})
        fi
    done
}

Start (){
    if ! ps -ef|grep -v grep|grep "inotifywait"; then
        (Chk_File) &
    fi
    exec ${php_fpm} -F
}

Start
