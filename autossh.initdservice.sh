#! /bin/sh
# author: Clément Désiles
# date: 01/08/2016
# source: https://www.it-react.com/index.php/2020/01/06/how-to-setup-reverse-ssh-tunnel-on-linux/
# source: https://gist.github.com/suma/8134207
# source: http://stackoverflow.com/questions/34094792/autossh-pid-is-not-equal-to-the-one-in-pidfile-when-using-start-stop-daemon

### BEGIN INIT INFO
# Provides:          autossh
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: autossh initscript
# Description:       establish a tunnelled connexion for remote access
### END INIT INFO

. /etc/environment
. /lib/init/vars.sh
. /lib/lsb/init-functions

TUNNEL_HOST=51.38.185.232
TUNNEL_USER=user
TUNNEL_PORT_HTTP=8080
TUNNEL_PORT=3334
MONITOR_PORT=9924
KEY_PATH=/home/user/.ssh/private_key

NAME=autossh
DAEMON=/usr/lib/autossh/autossh
AUTOSSH_ARGS="-M $MONITOR_PORT -f"
SSH_ARGS="-nNTv -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o IdentitiesOnly=yes -o StrictHostKeyChecking=no \
         -i $KEY_PATH -R $TUNNEL_PORT_HTTP:localhost:1880 -R $TUNNEL_PORT:localhost:22 $TUNNEL_USER@$TUNNEL_HOST"

DESC="autossh for reverse ssh"
SCRIPTNAME=/etc/init.d/$NAME
DAEMON_ARGS=" $AUTOSSH_ARGS $SSH_ARGS"

# Export PID for autossh
AUTOSSH_PIDFILE=/var/run/$NAME.pid
export AUTOSSH_PIDFILE

do_start() {
        start-stop-daemon --start --background --name $NAME --exec $DAEMON --test > /dev/null || return 1
        start-stop-daemon --start --background --name $NAME --exec $DAEMON -- $DAEMON_ARGS    || return 2
}

do_stop() {
        start-stop-daemon --stop --name $NAME --retry=TERM/5/KILL/9 --pidfile $AUTOSSH_PIDFILE --remove-pidfile
        RETVAL="$?"
        [ "$RETVAL" = 2 ] && return 2
        start-stop-daemon --stop --oknodo --retry=0/5/KILL/9 --exec $DAEMON
        [ "$?" = 2 ] && return 2
        return "$RETVAL"
}

case "$1" in
  start)
        log_daemon_msg "Starting $DESC" "$NAME"
        do_start
        case "$?" in
                0|1) log_end_msg 0 ;;
                2) log_end_msg 1 ;;
        esac
        ;;
  stop)
        log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
                0|1) log_end_msg 0 ;;
                2) log_end_msg 1 ;;
        esac
        ;;
  status)
        status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|status|restart}" >&2
        exit 3
        ;;
esac
