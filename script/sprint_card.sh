#!/bin/bash

# taken from:
# http://samat.org/weblog/20070128-sprints-evdo-mobile-broadband-on-ubuntu-linux.html


cat > /etc/ppp/peers/sprint <<__EOS_

/dev/ttyUSB3    # modem
921600          # faster than this has no effect, and actually can be detrimental
defaultroute    # use cellular network for default route
usepeerdns      # use the DNS servers from the remote network
#nodetach        # keep pppd in the foreground
#debug
crtscts        # hardware flow control
lock            # lock the serial port
noauth          # don't expect the modem to authenticate itself
local          # don't use Carrier Detect or Data Terminal Ready
persist        # Redial if connection lost
user
ppp
holdoff 5      # Reconnect after 5s on connection loss

lcp-echo-failure 4      # prevent timeouts
lcp-echo-interval 65535 # prevent timeouts

connect        "/usr/sbin/chat -v -f /etc/chatscripts/sprint-connect"
disconnect      "/usr/sbin/chat -v -f /etc/chatscripts/sprint-disconnect"

__EOS_

cat > /etc/chatscripts/sprint-connect <<__EOS__
TIMEOUT 10
ABORT 'BUSY'
ABORT 'NO ANSWER'
ABORT 'ERROR'
SAY 'Starting Sprint...\n'

# Get the modem's attention and reset it.
""      'ATZ'
# E0=No echo, V1=English result codes
OK    'ATE0V1'

# List signal quality
'OK' 'AT+CSQ'

'OK' 'ATDT#777'
CONNECT

__EOS__

cat > /etc/chatscripts/sprint-disconnect <<__EOS__
"" "\K"
"" "+++ATH0"
SAY "Disconnected from Sprint."
__EOS__


cat > /etc/ppp/ip-up.d/zzz-fix-route t <<__EOS__

#!/bin/sh
/sbin/route del default gw 0.0.0.0      # Remove nonsense route
/sbin/route add default gw $PPP_REMOTE  # Add correct route
__EOS__