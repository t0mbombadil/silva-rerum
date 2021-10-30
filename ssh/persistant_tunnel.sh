#!\bin\bash

LOCAL_SSH_PORT=443
REMOTE_SSH_PORT=2222

LOCAL_SSH_ADDRESS=127.0.0.1
REMOTE_SSH_ADDRESS=x.x.x.x
PROXY_HOST=malina-proxy

SSH_COMMAND="ssh -N -R ${REMOTE_SSH_ADDRESS}:${REMOTE_SSH_PORT}:${LOCAL_SSH_ADDRESS}:${LOCAL_SSH_PORT} ${PROXY_HOST}"
LOG_FILE=~/.ssh/tunnel-log.log
MAX_FAILS=150
FAIL_NR_FILE=~/.ssh/persistant_tunnel/failCount


# FUNCTIONS



# MAIN

failCount=0
if [ -f $FAIL_NR_FILE ]; then
	failCount=$(cat $FAIL_NR_FILE)
	echo "fails: $failCount"
	if [ $failCount -gt ${MAX_FAILS} ]; then
		echo "Fail maximum reached: $failCount. Rebooting system" >> ${LOG_FILE}
		echo "path: $(realpath ${FAIL_NR_FILE})" >> ${LOG_FILE}
		sudo rm -f ${FAIL_NR_FILE}
		sudo shutdown -r now
		exit
	fi
else
	echo $failCount > $FAIL_NR_FILE
fi	

#  Do a request to a site we own regularly so we can remotely check if the Raspberry Pi is alive and what it's public IP is.
curl http://${REMOTE_SSH_ADDRESS} /dev/null 2>&1

echo 1 > /proc/sys/net/ipv4/tcp_mtu_probing
#  Check if there was a tunnel launched with the same command, otherwise, start one
if [ $(pgrep -f -x "$SSH_COMMAND" | wc -l) -eq 0 ]; then
	$SSH_COMMAND &
	PREV_PID=$!
	echo "$(date): No tunnel was active: starting tunnel with pid: ${PREV_PID}." >> "${LOG_FILE}"
fi

MATCHING_LISTENS=$(ssh ${PROXY_HOST} "netstat -an" | egrep "tcp.*${REMOTE_SSH_PORT}.*LISTEN")
LISTEN_CHECK_RTN=$?
#  Count listens using awk, wc -l won't work if there is no trailing newline.
NUM_MATCHING_LISTENS=$(echo -en "${MATCHING_LISTENS}" | awk 'END{print NR}')

#  Re-start the tunnel if we can't ssh into the remote and verify that the tunnel is working
if [ ${LISTEN_CHECK_RTN} -ne 0 ] ; then
	pkill -f -x "$SSH_COMMAND"
	$SSH_COMMAND &
	PREV_PID=$!
	echo "$(date): Failed to check for active tunnel, restarted tunnel.  New pid: ${PREV_PID}." >> "${LOG_FILE}"
	echo $(expr $failCount + 1) > ${FAIL_NR_FILE}

elif [ ${NUM_MATCHING_LISTENS} -lt 1 ] ; then
	pkill -f -x "$SSH_COMMAND"
	$SSH_COMMAND &
	PREV_PID=$!
	echo "$(date): No matching listens found in proxy server, restarted tunnel.  New pid: ${PREV_PID}." >> "${LOG_FILE}"
	echo $(expr $failCount + 1) > ${FAIL_NR_FILE}

else
	echo "$(date): Tunnel appears to be active on remote, do nothing." >> "${LOG_FILE}"
fi
