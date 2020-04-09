#!/bin/bash

# This script is used for firmware upgrades.  It checks for the existence of an
# upgrade.tar.gz file in ${SNAP_DATA}/upgrades/, and if found, untars the file
# and runs the runme.sh script inside.

# SNAP_DATA: /var/snap/pelion-edge/current/
# path copied from snap-pelion-edge/snap/hooks/install
UPGRADE_DIR=${SNAP_DATA}/upgrades
UPGRADE_TGZ=${UPGRADE_DIR}/upgrade.tar.gz
UPGRADE_HDR=${UPGRADE_DIR}/header.bin
UPGRADE_VER=${UPGRADE_DIR}/platform_version
UPGRADE_WORKDIR=/tmp/pelion-edge-upgrade/
ACTIVE_HDR=${SNAP_DATA}/userdata/mbed/header.bin
ACTIVE_VER=${SNAP_DATA}/etc/platform_version

echo "Checking for ${UPGRADE_TGZ}"
if [ -e "${UPGRADE_TGZ}" ]; then
	mkdir -p "${UPGRADE_WORKDIR}"
	tar -xzf "${UPGRADE_TGZ}" -C "${UPGRADE_WORKDIR}"
	# remove the upgrade tgz file so that we don't fall into an upgrade loop
	rm "${UPGRADE_TGZ}"
	pushd "${UPGRADE_WORKDIR}"
	# copy the new version file to the upgrade folder to be copied
	# into its final destination after the upgrade finishes
	if [ -e platform_version ]; then
		cp platform_version "${UPGRADE_VER}"
	else
		echo "ERROR: upgrade.tar.gz did not contain platform_version"
		# return success to allow edge-core to continue booting
		return 0
	fi
	if [ -x runme.sh ]; then
		./runme.sh
	else
		echo "ERROR: upgrade.tar.gz did not contain runme.sh"
	fi
	popd
fi

if [ -e "${UPGRADE_HDR}" ]; then
	# copy the firmware header to persistent storage for later
	# use by the arm_update_active_details.sh script
	echo "Moving the new firmware header to persistent storage ${ACTIVE_HDR}"
	mv "${UPGRADE_HDR}" "${ACTIVE_HDR}"
fi

if [ -e "${UPGRADE_VER}" ]; then
	echo "Moving the new firmware version file to final location ${ACTIVE_VER}"
	mv "${UPGRADE_VER}" "${ACTIVE_VER}"
fi

if [ -d "${UPGRADE_WORKDIR}" ]; then
	echo "Deleting the upgrade workdir ${UPGRADE_WORKDIR}"
	rm -rf "${UPGRADE_WORKDIR}"
fi
