################################################################################
# 
# Objet : Automatisation of the connection for the peer 
# 
# version : 1.2
#
# Author : Axel OSCAR
#
# Infos :
#   - put argument which the numbre of the peer 1 to 5
# 
################################################################################

#!/bin/bash

# Argument checking
if [ -z "$1" ]; then
  echo "Usage: $0 <number>"
  echo "Where <number> is a value from 1 to 5."
  exit 1
fi

if ! [[ "$1" =~ ^[1-5]$ ]]; then
  echo "Error: The argument must be a number from 1 to 5."
  exit 1
fi

# Assign the argument for our variable
NUMBER=$1

# Define the peer variables
PEER_ADDRESS="peer0.pro${NUMBER}.research-network.com:7051"
LOCALMSPID="Provider${NUMBER}MSP"
TLS_ROOTCERT_FILE="/opt/gopath/fabric-server/research-network/crypto-config/peerOrganizations/pro${NUMBER}.research-network.com/peers/peer0.pro${NUMBER}.research-network.com/tls/ca.crt"
MSPCONFIGPATH="/opt/gopath/fabric-server/research-network/crypto-config/peerOrganizations/pro${NUMBER}.research-network.com/users/Admin@pro${NUMBER}.research-network.com/msp"
ORDERER_CA="/opt/gopath/fabric-server/research-network/crypto-config/ordererOrganizations/research-network.com/orderers/orderer.research-network.com/msp/tlscacerts/tlsca.research-network.com-cert.pem"

# Execute the Docker command to connect to the peer's CLI
docker exec -e "CORE_PEER_LOCALMSPID=$LOCALMSPID" \
            -e "CORE_PEER_TLS_ROOTCERT_FILE=$TLS_ROOTCERT_FILE" \
            -e "CORE_PEER_MSPCONFIGPATH=$MSPCONFIGPATH" \
            -e "CORE_PEER_ADDRESS=$PEER_ADDRESS" \
            -it cli bash -c "
            export ORDERER_CA=$ORDERER_CA; \
            peer channel list; \
            exec /bin/bash"