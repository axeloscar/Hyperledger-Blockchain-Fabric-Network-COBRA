# Hyperledger Fabric Network for COBRA

## ⚙️ Overview
This repository provides a step-by-step guide to deploying a Hyperledger Fabric blockchain network using Docker. Its provides a full Dockerized Hyperledger Fabric network tailored for integration with the **COBRA framework** and designed as **permissioned blockchain** using **Raft consensus**, with **5 organizations** (providers), each hosting a peer, and a single shared channel.

The network is intended for **research, simulation, and prototyping** of cooperative task offloading in UAV/Edge Computing environments, aligned with 6G and NTN (Non-Terrestrial Networks) paradigms. It supports identity management via **Certificate Authorities (CAs)**, and uses **LevelDB** for state persistence.

> [!CAUTION]  
> This setup is for **experimental and research use only or proof of work**. It is **not hardened for production deployment**.
> All the configuration files that will be described later are in the researhc folder. It is important to respect the architecture of the folder so that everything works.

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
configtxgen -profile ChannelCoop -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channelcoop
```
# Repeat for each provider:
```bash
configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider1Anchor.tx -channelID channelcoop -asOrg Provider1MSP
```
> [!TIP]  
> Run these commands from within the `fabric-samples` path or ensure all Fabric binaries are in your `$PATH`.

### 3. Launch the Network with Docker

```bash
docker-compose -f ../docker-compose-cli.yaml up -d
```

### 4. Join Peers to the Channel

For each peer (in separate terminals):

```bash
export ORDERER_CA=/opt/gopath/fabric-samples/research-network/crypto-config/ordererOrganizations/research-network.com/orderers/orderer.research-network.com/msp/tlscacerts/tlsca.research-network.com-cert.pem

peer channel create -o orderer.research-network.com:7050 -c channelcoop -f ./channel-artifacts/channel.tx --tls --cafile $ORDERER_CA
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

