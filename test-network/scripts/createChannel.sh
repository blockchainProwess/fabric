#!/bin/bash

source scriptUtils.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${CHANNEL2_NAME:="farmingchannel"}
: ${CHANNEL3_NAME:="cropchannel"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

# import utils
. scripts/envVar.sh

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelTx() {

	set -x
	configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate channel configuration transaction..."
	fi
}

createChannelTx2() {

	set -x
	configtxgen -profile FarmingChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL2_NAME}.tx -channelID $CHANNEL2_NAME
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate channel configuration transaction..."
	fi
}

createChannelTx3() {

	set -x
	configtxgen -profile CropChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL3_NAME}.tx -channelID $CHANNEL3_NAME
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate channel configuration transaction..."
	fi
}

createAncorPeerTx() {

	for orgmsp in Org1MSP Org2MSP Org3MSP Org4MSP; do

	infoln "Generating anchor peer update transaction for ${orgmsp}"
	set -x
	configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate anchor peer update transaction for ${orgmsp}..."
	fi
	done

}

createAncorPeerTx2() {

	for orgmsp in Org1MSP Org2MSP Org3MSP Org4MSP; do

	infoln "Generating anchor peer update transaction for ${orgmsp}"
	set -x
	configtxgen -profile FarmingChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors2.tx -channelID $CHANNEL2_NAME -asOrg ${orgmsp}
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate anchor peer update transaction for ${orgmsp}..."
	fi
	done

}

createAncorPeerTx3() {

	for orgmsp in Org1MSP Org2MSP Org3MSP Org4MSP; do

	infoln "Generating anchor peer update transaction for ${orgmsp}"
	set -x
	configtxgen -profile CropChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors3.tx -channelID $CHANNEL3_NAME -asOrg ${orgmsp}
	res=$?
	{ set +x; } 2>/dev/null
	if [ $res -ne 0 ]; then
		fatalln "Failed to generate anchor peer update transaction for ${orgmsp}..."
	fi
	done

}

createChannel() {
	setGlobals 1
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	successln "Channel '$CHANNEL_NAME' created"
}

createChannel2() {
	infoln "Entered into channel creation 2"
	setGlobals 1
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o localhost:7050 -c $CHANNEL2_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL2_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL2_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	successln "Channel '$CHANNEL2_NAME' created"
}

createChannel3() {
	infoln "Entered into channel creation 2"
	setGlobals 1
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		set -x
		peer channel create -o localhost:7050 -c $CHANNEL3_NAME --ordererTLSHostnameOverride orderer.example.com -f ./channel-artifacts/${CHANNEL3_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL3_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
		res=$?
		{ set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	successln "Channel '$CHANNEL2_NAME' created"
}
# queryCommitted ORG
joinChannel() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

joinChannel2() {
  infoln "Entered into joining channel creation 2"
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL2_NAME.block >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL2_NAME' "
}

joinChannel3() {
  infoln "Entered into joining channel creation 2"
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/$CHANNEL3_NAME.block >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL3_NAME' "
}

updateAnchorPeers() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
		peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
  sleep $DELAY
}

updateAnchorPeers2() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
		peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL2_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors2.tx --tls --cafile $ORDERER_CA >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL2_NAME'"
  sleep $DELAY
}

updateAnchorPeers3() {
  ORG=$1
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
		peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL3_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors3.tx --tls --cafile $ORDERER_CA >&log.txt
    res=$?
    { set +x; } 2>/dev/null
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
  verifyResult $res "Anchor peer update failed"
  successln "Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL3_NAME'"
  sleep $DELAY
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

FABRIC_CFG_PATH=${PWD}/configtx

## Create channeltx
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

infoln "Generating channel create transaction '${CHANNEL2_NAME}.tx'"
createChannelTx2

infoln "Generating channel create transaction '${CHANNEL3_NAME}.tx'"
createChannelTx3


## Create anchorpeertx
infoln "Generating anchor peer update transactions"
createAncorPeerTx

infoln "Generating anchor peer update transactions"
createAncorPeerTx2 

infoln "Generating anchor peer update transactions"
createAncorPeerTx3

FABRIC_CFG_PATH=$PWD/../config/

## Create channel
infoln "Creating channel ${CHANNEL_NAME}"
createChannel

## Join all the peers to the channel
infoln "Join Org1 peers to the channel..."
joinChannel 1
infoln "Join Org2 peers to the channel..."
joinChannel 2
infoln "Join Org3 peers to the channel..."
joinChannel 3
infoln "Join Org4 peers to the channel..."
joinChannel 4


## Set the anchor peers for each org in the channel
infoln "Updating anchor peers for org1..."
updateAnchorPeers 1
infoln "Updating anchor peers for org2..."
updateAnchorPeers 2
infoln "Updating anchor peers for org3..."
updateAnchorPeers 3
infoln "Updating anchor peers for org4..."
updateAnchorPeers 4

successln "Channel successfully joined"


infoln "Creating channel ${CHANNEL2_NAME}"
createChannel2

## Join all the peers to the channel2
infoln "Join Org1 peers to the channel2..."
joinChannel2 1
infoln "Join Org2 peers to the channel2..."
joinChannel2 2
infoln "Join Org3 peers to the channel2..."
joinChannel2 3
infoln "Join Org4 peers to the channel2..."
joinChannel2 4

## Set the anchor peers for each org in the channel2
infoln "Updating anchor peers for org1... channel2"
updateAnchorPeers2 1
infoln "Updating anchor peers for org2... channel2"
updateAnchorPeers2 2
infoln "Updating anchor peers for org3... channel2"
updateAnchorPeers2 3
infoln "Updating anchor peers for org4... channel2"
updateAnchorPeers2 4

successln "Channel2 successfully joined"

infoln "Creating channel ${CHANNEL2_NAME}"
createChannel3

## Join all the peers to the channel2
infoln "Join Org1 peers to the channel2..."
joinChannel3 1
infoln "Join Org2 peers to the channel2..."
joinChannel3 2
infoln "Join Org3 peers to the channel2..."
joinChannel3 3
infoln "Join Org4 peers to the channel2..."
joinChannel3 4

## Set the anchor peers for each org in the channel2
infoln "Updating anchor peers for org1... channel2"
updateAnchorPeers3 1
infoln "Updating anchor peers for org2... channel2"
updateAnchorPeers3 2
infoln "Updating anchor peers for org3... channel2"
updateAnchorPeers3 3
infoln "Updating anchor peers for org4... channel2"
updateAnchorPeers3 4

successln "Channel3 successfully joined"

exit 0
