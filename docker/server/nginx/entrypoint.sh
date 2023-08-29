#!/bin/sh

# nginx default entrypoint

set -e

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then
    if /usr/bin/find "/docker-entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "$0: /docker-entrypoint.d/ is not empty, will attempt to perform configuration"

        echo >&3 "$0: Looking for shell scripts in /docker-entrypoint.d/"
        find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "$0: Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "$0: Ignoring $f, not executable";
                    fi
                    ;;
                *) echo >&3 "$0: Ignoring $f";;
            esac
        done

        echo >&3 "$0: Configuration complete; ready for start up"
    else
        echo >&3 "$0: No files found in /docker-entrypoint.d/, skipping configuration"
    fi
fi

#custom
#echo >&3 "$0: Configuring syslog and fail2ban"
## Start syslog service
#echo >&3 "$0: Starting syslog service..."
#exec rsyslogd -n || {
#    echo >&3 "$0: Failed to start syslog service";
#    exit 1;
#}

# Start fail2ban
#echo >&3 "$0: Starting fail2ban service..."
#exec fail2ban-server -f -x -v start || {
#    echo >&3 "$0: Failed to start fail2ban service";
#    exit 1;
#}

#finish nginx default entrypoint
exec "$@" 
