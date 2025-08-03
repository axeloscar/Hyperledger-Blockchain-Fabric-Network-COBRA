Voici le **README.md final** du nouveau dépôt **Hyperledger Fabric Network for COBRA**, version complète, exhaustive, claire et pensée pour un public de recherche :

---

````markdown
# Hyperledger Fabric Network for COBRA

## ⚙️ Overview
This repository provides a full Dockerized Hyperledger Fabric network tailored for integration with the **COBRA framework**. It sets up a **permissioned blockchain** using **Raft consensus**, with **5 organizations** (providers), each hosting a peer, and a single shared channel.

The network is intended for **research, simulation, and prototyping** of cooperative task offloading in UAV/Edge Computing environments, aligned with 6G and NTN (Non-Terrestrial Networks) paradigms. It supports identity management via **Certificate Authorities (CAs)**, and uses **LevelDB** for state persistence.

> ⚠️ This setup is for experimental use only. Not intended for production deployment.

---

## 📋 Short Description (for GitHub)
Hyperledger Fabric network for COBRA: 5 peers, 1 Raft orderer, full Docker setup, cryptographic tools, channel configuration, and CLI interaction. Designed for cooperative UAV/Edge offloading in 6G simulations.

---

## 🧱 Architecture Summary
- **5 Organizations (Providers)**:
  - Each with 1 Peer Node
  - Each with its own Certificate Authority (CA)
- **1 Orderer Node** using Raft consensus
- **1 Shared Channel**: `channelcoop`
- **State Database**: LevelDB
- **Security**: TLS enabled, MSP-based identity management

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

### 1. Generate Cryptographic Material

```bash
cd research-network/
cryptogen generate --config=crypto-config.yaml --output=crypto-config/
```

### 2. Create Genesis Block & Channel Configuration

```bash
configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID channelorderer
configtxgen -profile ChannelCoop -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channelcoop
# Repeat for each provider:
configtxgen -profile ChannelCoop -outputAnchorPeersUpdate ./channel-artifacts/Provider1Anchor.tx -channelID channelcoop -asOrg Provider1MSP
```

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

### 5. Update Anchor Peers

```bash
peer channel update -o orderer.research-network.com:7050 -c channelcoop -f ./channel-artifacts/Provider1Anchor.tx --tls --cafile $ORDERER_CA
```

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
│   ├── channel-artifacts/         # Genesis block, channel tx, anchors
│   ├── crypto-config/             # TLS + MSP certs (generated)
│   └── docker/                    # Compose files for peers/orderer
│       ├── docker-compose.yaml
│       └── peer-docker.yaml
├── docker-compose-cli.yaml        # CLI service + environment
├── .env                           # COMPOSE_PROJECT_NAME=net
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

---

## 🧪 Troubleshooting

| Error                                      | Possible Cause              | Fix                                                |
| ------------------------------------------ | --------------------------- | -------------------------------------------------- |
| `BAD_REQUEST` on channel creation          | Wrong MSP path or CA config | Check `CORE_PEER_MSPCONFIGPATH`                    |
| `panic: Failed validating bootstrap block` | Capabilities not set        | Ensure `V2_0: true` in all `Capabilities` sections |
| `certificate signed by unknown authority`  | TLS misconfig or Go version | Double-check cert paths and use Go ≤ 1.18          |
| `endorser org unknown`                     | Org not defined properly    | Fix `configtx.yaml` org list and crypto material   |

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

