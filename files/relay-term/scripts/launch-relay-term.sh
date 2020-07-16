while [ ! -f $SNAP_DATA/relayterm-config.json ]; do sleep 1; done

exec bin/node $SNAP/wigwag/wigwag-core-modules/relay-term/src/index.js \
    start $SNAP_DATA/relayterm-config.json
