# All comand use to create the network:
***Below are all the commands to use in raw form if you want to automate the process.***
```
	mkdir research-network
	vim crypto-config.yaml
	../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config
	vim configtx.yaml
	../bin/configtxgen -profile OrdererRaft -outputBlock ./channel-artifacts/genesis.block -channelID channelorderer
	../bin/configtxgen -profile ChannelCoop -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channelcoop

	../bin/configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider1Anchor.tx -channelID channelcoop -asOrg Provider1MSP
	../bin/configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider2Anchor.tx -channelID channelcoop -asOrg Provider2MSP
	../bin/configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider3Anchor.tx -channelID channelcoop -asOrg Provider3MSP
	../bin/configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider4Anchor.tx -channelID channelcoop -asOrg Provider4MSP
	../bin/configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider5Anchor.tx -channelID channelcoop -asOrg Provider5MSP

	mkdir docker
	cd docker/

	vim docker-compose.yaml
	vim peer-docker.yaml
	cd ..
	vim docker-compose-cli.yaml
	echo COMPOSE_PROJECT_NAME=net > .env
	docker-compose -f docker-compose-cli.yaml up -d

**One terminal for each command :**
	docker exec -e "CORE_PEER_LOCALMSPID=Provider1MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro1.research-network.com/peers/peer0.pro1.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro1.research-network.com/users/Admin@pro1.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro1.research-network.com:7051" -it cli bash
	docker exec -e "CORE_PEER_LOCALMSPID=Provider2MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro2.research-network.com/peers/peer0.pro2.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro2.research-network.com/users/Admin@pro2.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro2.research-network.com:7051" -it cli bash
	docker exec -e "CORE_PEER_LOCALMSPID=Provider3MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro3.research-network.com/peers/peer0.pro3.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro3.research-network.com/users/Admin@pro3.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro3.research-network.com:7051" -it cli bash
	docker exec -e "CORE_PEER_LOCALMSPID=Provider4MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro4.research-network.com/peers/peer0.pro4.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro4.research-network.com/users/Admin@pro4.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro4.research-network.com:7051" -it cli bash
	docker exec -e "CORE_PEER_LOCALMSPID=Provider5MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro5.research-network.com/peers/peer0.pro5.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro5.research-network.com/users/Admin@pro5.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro5.research-network.com:7055" -it cli bash


**In all terminal :**
	export ORDERER_CA=/opt/gopath/fabric-samples/research-network/crypto-config/ordererOrganizations/research-network.com/orderers/orderer.research-network.com/msp/tlscacerts/tlsca.research-network.com-cert.pem

**One terminal :**
	peer channel create -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/channel.tx --tls --cafile $ORDERER_CA

**In all terminal :**
	peer channel join -b channelcoop.block --tls --cafile $ORDERER_CA
	peer channel update -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/Provider1Anchor.tx --tls --cafile $ORDERER_CA
	peer channel update -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/Provider2Anchor.tx --tls --cafile $ORDERER_CA
	peer channel update -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/Provider3Anchor.tx --tls --cafile $ORDERER_CA
	peer channel update -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/Provider4Anchor.tx --tls --cafile $ORDERER_CA
	peer channel update -o orderer.research-network.com:7050 -c channelcoop -f /opt/gopath/fabric-samples/research-network/channel-artifacts/Provider5Anchor.tx --tls --cafile $ORDERER_CA
```
