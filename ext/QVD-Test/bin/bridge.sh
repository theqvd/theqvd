BRIDGE=qvdnet0
IFACE=$(/sbin/ip route list | awk '/^default / { print $5 }')
GATEWAY=$(/sbin/ip route list | awk '/^default / { print $3 }')
ADDRESS=$(ip addr show $IFACE | awk '/inet / { print $2 }')
brctl addbr $BRIDGE
brctl addif $BRIDGE $IFACE
ifconfig $IFACE 0.0.0.0 up
ifconfig $BRIDGE $ADDRESS up
ip route add default via $GATEWAY dev $BRIDGE
