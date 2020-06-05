RELAY_ID=`jq -r .deviceID ${SNAP_DATA}/userdata/edge_gw_identity/identity.json`
SITE_ID=`jq -r .OU ${SNAP_DATA}/userdata/edge_gw_identity/identity.json`

if [ $? -ne 0 ]; then
    echo "Unable to extract device ID from identity.json"
    exit 1
fi

echo $RELAY_ID > ${SNAP_DATA}/userdata/edge_gw_identity/device_id
echo $SITE_ID > ${SNAP_DATA}/userdata/edge_gw_identity/site_id
exec ${SNAP}/wigwag/system/bin/compose-cloud-add-device.sh ${SNAP_DATA}/userdata/edge_gw_identity

exec ${SNAP}/wigwag/system/bin/devicedb start -conf $SNAP_DATA/wigwag/etc/devicejs/devicedb.yaml
