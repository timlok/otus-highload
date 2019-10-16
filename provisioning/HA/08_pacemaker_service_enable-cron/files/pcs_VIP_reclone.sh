#!/usr/bin/env bash
#set -x
/usr/bin/echo "############ start recloning script ############"
/usr/bin/date
/usr/bin/sleep 20
/usr/bin/echo "############ crm_mon --group-by-node --one-shot -Rof --inactive ############"
/usr/sbin/crm_mon --group-by-node --one-shot -Rof --inactive
/usr/bin/echo "############ pcs resource unclone cluster_vip ############"
/usr/sbin/pcs resource unclone cluster_vip
/usr/bin/sleep 2
/usr/bin/echo "############ pcs resource cleanup ############"
/usr/sbin/pcs resource cleanup
/usr/bin/sleep 2
/usr/bin/echo "############ pcs resource clone cluster_vip ############"
/usr/sbin/pcs resource clone cluster_vip
/usr/bin/sleep 6
/usr/bin/echo "############ crm_mon --group-by-node --one-shot -Rocf --inactive ############"
/usr/sbin/crm_mon --group-by-node --one-shot -Rocf --inactive
/usr/bin/echo "############ end recloning script ############"
