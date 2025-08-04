# Hyperledger Fabric Network for COBRA

## ⚙️ Overview
This repository provides a step-by-step guide to deploying a Hyperledger Fabric blockchain network using Docker. Its provides a full Dockerized Hyperledger Fabric network tailored for integration with the **COBRA framework** and designed as **permissioned blockchain** using **Raft consensus**, with **5 organizations** (providers), each hosting a peer, and a single shared channel.

The network is intended for **research, simulation, and prototyping** of cooperative task offloading in UAV/Edge Computing environments, aligned with 6G and NTN (Non-Terrestrial Networks) paradigms. It supports identity management via **Certificate Authorities (CAs)**, and uses **LevelDB** for state persistence.

> [!CAUTION]  
> This setup is for **experimental and research use only or proof of work**. It is **not hardened for production deployment**.
> All the configuration files described below are located in the research-network folder. It is important to respect the architecture of the folder so that everything works.

> [!NOTE]
> ***For a production use a complete architecture will have to be created. You can find all the necessary information on the Hyperledger Wiki.***
> 
> ***Do not hesiate to contribute or signal if you see errors or if you have any questions***
>
> ***As i say, this project was created to be used with my COBRA framework for my research on creating a collaboration framework using blockchain for Cooperative Edge composed of Edge Server and UAV. "[https://github.com/AxelOscar/COBRA](https://github.com/axeloscar/Cobra-Framework/tree/main)"***

> [!WARNING]
> The configuration files will only allow you to create a well-defined blockchain if this does not correspond to your expectations you will have to modify them, so base yourself on these files to make the modifications, and be careful most of the problems you may encounter will be crypto errors due to a bad path to the crypto files

---

## 🧱 Architecture Summary
- **5 Organizations (Providers)**:
  - Each with 1 Peer Node
  - Each with its own Certificate Authority (CA)
- **1 Orderer Node** using Raft consensus
- **1 Shared Channel**: `channelcoop`
- **State Database**: LevelDB
- **Security**: TLS enabled, MSP-based identity management

> [!NOTE]  
> All configuration files are organized in the `research-network/` folder for clarity and reproducibility.
---

## ✅ Prerequisites
Tested on **Ubuntu 21.04** with:
- Docker & Docker Compose
- Hyperledger Fabric Binaries (v2.x or higher)
- Hyperledger Fabric CA tools
```bash
curl -sSLO https://github.com/hyperledger/fabric-ca/releases/download/v1.5.12/hyperledger-fabric-ca-linux-amd64-1.5.12.tar.gz
tar -xzvf hyperledger-fabric-ca-linux-amd64-1.5.12.tar.gz
````
> [!TIP]
> Use Go v1.18 or lower to avoid certificate validation issues with Fabric CA

---

## 🧰 Setup Instructions
> [!NOTE]
> Before proceeding to the following, you have to  decide in advance on the architecture of the blockchain, how many organizations and peers, combination of channels and orders, what type of consensus CTO (RAFT) or Byzantine-Fault (BFT) you will use and have. For us we have define this above. 

### 1. Generate Cryptographic Material
After extracting the archive you will have a folder named "fabric-samples" we will create a folder in this folder which will contain all the configuration and deployment elements of our network in my case it will be called "research-network".
```
      mkdir fabric-samples/research-network
```

To generate cryptographic material for all network entities we using the cryptogen tool.
```bash
cd research-network/
../bin/cryptogen generate --config=crypto-config.yaml --output=crypto-config/
```

### 2. Create Genesis Block & Channel Configuration

This step is crucial in setting up the Hyperledger Fabric network. The genesis block and channel configuration define the structure of your blockchain network and how different nodes (Orderer and Peers) interact with each other.

**Genesis Block:** This is the first block of the blockchain that initializes the Orderer service. It contains the configuration of the Orderer and the setup for the initial network.
**Channel Configuration:** Channels are used to facilitate private and secure communication between a subset of network members. Each channel has its own ledger and smart contract instances.

Generate the Genesis Block for the Orderer:
```bash
../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID channelorderer
```
Generate Channel Configuration:
```bash
../bin/configtxgen -profile ChannelCoop -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channelcoop
```
Generate Channel Configuration - Repeat for each provider:
```bash
configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider1Anchor.tx -channelID channelcoop -asOrg Provider1MSP
```
> [!TIP]  
> Run these commands from within the `fabric-samples` path or ensure all Fabric binaries are in your `$PATH`.

This file defines the structure of the blockchain network, specifying the organizations, policies, and capabilities. It is used by the configtxgen tool to generate the genesis block and other artifacts for channel creation.

Key Sections in configtx.yaml:
- Organizations: Defines the details for each organization (Orderer and Providers) in the network, including their identities, policies, and anchor peers.
- Capabilities: Specifies the feature set available for the channel and application.
- Application: Defines the settings for the chaincode lifecycle and policies for reading, writing, and validating transactions.
- Orderer (Raft Configuration): Defines the settings for the ordering service, which ensures the order of transactions in the blockchain.
- Channel: Configures the policies for creating and managing channels in the network.
- Profiles: Contains different configuration profiles that can be used to generate the genesis block and channel artifacts.

> [!TIP]
> To increase the number of providers in your network, you need to make changes in the configtx.yaml file as well as the crypto-config.yaml file to ensure that the new providers are properly integrated.
> Add a New Provider in the crypto-config.yaml. Follow the same format used for the existing providers to add a new provider, say Provider7.
> Modify the configtx.yaml File: Under the Organizations section, add a new entry for the new provider and Update the Profiles Section, add the new provider to both the Consortium and Channel profiles to ensure it is included in the network
> Finally to scale up the architecture:
> - Increase the Orderer Nodes: If you need to scale the Orderer service, you can add additional orderer nodes under the OrdererOrgs section by specifying more hostnames.
> - Add More Channels: To create a new channel, add its definition in the Profiles section and use configtxgen to generate its transaction file.
> - Adjust Batch Size for Higher Throughput: Increase the MaxMessageCount and PreferredMaxBytes in the Orderer configuration to handle larger volumes of transactions.

### 3. Launch the Network with Docker

In this step, we will configure Docker to set up the Hyperledger Fabric network environment. Docker Compose is used to define and manage multiple containers, including the Orderer and Peer nodes, which form the backbone of our blockchain network. The Docker configuration also includes settings for the CLI container that will be used to interact with the network.

Docker Compose files provide the environment setup for each component in the Hyperledger Fabric network. They specify the services, environment variables, and ports for each node. This setup allows you to deploy a distributed blockchain network across multiple nodes in a consistent and replicable manner.

#### Key Components of the Docker Configuration
##### Docker Compose Configuration for Peer Nodes
- Objective: Defines the environment and settings for each peer node in the network.
Environment Variables:
- Specifies important parameters like logging level, TLS certificates, and node identities.
- Ensures the peer nodes use secure communication by setting up TLS (Transport Layer Security).
- Volume Mapping: Maps the local directories to the Docker container to store the cryptographic material, configuration files, and ledger data.

##### Docker Compose Configuration for the Orderer Node
- Objective: Sets up the Orderer node, which is responsible for maintaining the order of transactions in the blockchain.
Orderer Environment Settings:
- Defines the location of the genesis block and TLS settings to ensure secure communication.
- Volume Mapping: Stores the Orderer’s configuration and data files securely in the Docker environment.

##### CLI Container Configuration
- Purpose: The CLI (Command Line Interface) container allows you to interact with the blockchain network for operations like chaincode installation, querying, and invoking transactions.
Environment Variables:
- Includes settings related to the peer address, MSP (Membership Service Provider), and the file paths for cryptographic keys.
- Volume Mapping: Maps the local directories containing chaincode and channel artifacts to the CLI container, enabling easy access to required files.


#### Command and Docker files
You have following Docker configuration files in the research-network/docker directory:
  - docker-compose.yaml: Defines the services for peers, orderer, and other network components.
  - peer.yaml: Configuration specific to peer nodes.
  - docker-compose-cli.yaml: To setup the docker, create in the Racine

To use it:

```bash
echo COMPOSE_PROJECT_NAME=net > .env
docker-compose -f ../docker-compose-cli.yaml up -d
```

> [!IMPORTANT]
> Restart Docker Containers if Necessary: If there is an error, stop all containers and remove the different command are in the Docker Commands (Cheat Sheet) part below

> [!TIP]
> Scaling the Network: Adding More Providers To add more providers or peer nodes to your existing setup, follow these steps:
> Update the peer-docker.yaml File
> - Add a new service definition for the additional peer node, making sure to update the environment variables with the new peer’s details.
> - Modify the docker-compose.yaml File
> Include the new peer service in the overall Docker Compose setup.
> - Ensure that the network settings and ports are correctly mapped to avoid conflicts with existing services.
> - Adjust Volumes and Networks
> Create new volumes for the additional peers to store their data.
> - Connect the new peer nodes to the existing Docker network for seamless communication.

### 4. Join Peers to the Channel

This step involves connecting each peer to the blockchain network, ensuring that they can interact with each other and the Orderer node to form a secure, decentralized network. You will use Docker commands to link the peers to the network and update their configurations to facilitate communication within the channel.
- For each peer in your network, you need to run specific Docker commands to set up the environment variables and connect to the blockchain network.
- Open a separate terminal window for each peer and execute the commands.
- The commands will set up the CORE_PEER_LOCALMSPID, the TLS root certificate, and other necessary configuration details for each peer node.

First for each in separate windows here is the command to enter in each peer and so execute the next command:
```bash
docker exec -e "CORE_PEER_LOCALMSPID=Provider1MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro1.research-network.com/peers/peer0.pro1.research-network.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/fabric-samples/research-network/crypto-config/peerOrganizations/pro1.research-network.com/users/Admin@pro1.research-network.com/msp" -e "CORE_PEER_ADDRESS=peer0.pro1.research-network.com:7051" -it cli bash
```
Add environement varible (In all terminal):
```bash
export ORDERER_CA=/opt/gopath/fabric-samples/research-network/crypto-config/ordererOrganizations/research-network.com/orderers/orderer.research-network.com/msp/tlscacerts/tlsca.research-network.com-cert.pem
```
Create and Join the Channel (In one terminal):
```bash
peer channel create -o orderer.research-network.com:7050 -c channelcoop -f ./channel-artifacts/channel.tx --tls --cafile $ORDERER_CA
```
Join each peer to the channel (In all terminal): 
```bash
peer channel join -b channelcoop.block --tls --cafile $ORDERER_CA
```
> [!WARNING]  
> Each peer must be joined **from its own CLI environment** with correct MSP and TLS configurations. Otherwise, errors will occur.

### 5. Update Anchor Peers

```bash
peer channel update -o orderer.research-network.com:7050 -c channelcoop -f ./channel-artifacts/Provider1Anchor.tx --tls --cafile $ORDERER_CA
```
> [!NOTE]  
> Update anchor peers after all peers have successfully joined the channel.

> [!IMPORTANT]
> Terminal Management: It's important to open a separate terminal for each peer to manage them independently. This practice helps in monitoring each node's behavior and catching any issues that may arise during the setup.
> Troubleshooting: If any peer fails to join the channel, recheck the environment variables and the certificate paths. Restarting the Docker containers may also help resolve connectivity issues.
> Scalability: To add more peers to the network, replicate the steps for each new peer node, making sure to adjust the environment variables and port mappings accordingly.


### 6. Verifying the Network Setup

Check Docker Logs: Use the following command to check the logs of any container:
```
      docker compose logs <container-id>
```
Verify the Network Setup: Ensure that all peers and the orderer are up and running without issues.

---

## 🧩 Integration with COBRA

This blockchain network is designed to operate seamlessly with the [COBRA Framework](https://github.com/AxelOscar/Cobra-Framework):

* Channel name: `channelcoop`
* Chaincode name: `cobra_algo`
* Peer/MSP structure compatible with the COBRA Go SDK (`cobra-config.yaml`)
* All credentials and certs are aligned for simulation and benchmark scenarios.

---

## 📁 Repository Structure

```
hyperledger-network-cobra/
├── research-network/
│   ├── crypto-config.yaml         # Defines orgs, peers, and users
│   ├── configtx.yaml              # Defines orderer and channel profiles
│   ├── docker-compose-cli.yaml    # CLI service + environment
│   └── docker/                    # Compose files for peers/orderer
│       ├── docker-compose.yaml
│       └── peer-docker.yaml
├── docs/                          # Troubleshooting and extension guides
│   ├── troubleshooting.md         # Troubleshooting exemple and solution
│   └── command_raw.yaml           # All in raw commands to automate the process
└── README.md                      # This file
```

---

## 🐳 Docker Commands (Cheat Sheet)

```bash
# Start network
docker-compose -f docker-compose-cli.yaml up -d

# Stop and clean everything
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker volume prune
docker network prune
```
> [!TIP]  
> If you see port conflicts or hanging containers, try restarting Docker entirely before retrying.

---

## 🧪 Troubleshooting

| Error                                      | Possible Cause              | Fix                                                |
| ------------------------------------------ | --------------------------- | -------------------------------------------------- |
| `BAD_REQUEST` on channel creation          | Wrong MSP path or CA config | Check `CORE_PEER_MSPCONFIGPATH`                    |
| `panic: Failed validating bootstrap block` | Capabilities not set        | Ensure `V2_0: true` in all `Capabilities` sections |
| `certificate signed by unknown authority`  | TLS misconfig or Go version | Double-check cert paths and use Go ≤ 1.18          |
| `endorser org unknown`                     | Org not defined properly    | Fix `configtx.yaml` org list and crypto material   |

> [!WARNING]  
> Most deployment errors are due to certificate misalignment or incorrect MSP configurations. Read logs carefully and compare file paths.

More detailed fixes and commands in [`docs/troubleshooting.md`](./docs/troubleshooting.md)

---

## 📈 Scaling the Network

To add more organizations or peers:

* Update `crypto-config.yaml` and `configtx.yaml`
* Regenerate crypto and channel artifacts
* Add peer services in `peer-docker.yaml`
* Join new peers to the channel and update anchor peers

---

## 🧾 License

Distributed under the **Apache 2.0 License** — see [`LICENSE`](./LICENSE) for more details.

---

**Author**: Axel Oscar
**Companion repo** to the [COBRA framework](https://github.com/AxelOscar/Cobra-Framework) for cooperative UAV & edge computing simulations using blockchain.

