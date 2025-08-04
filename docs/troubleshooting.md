# Troubleshooting: Hyperledger Fabric Network for COBRA

This guide covers frequent issues encountered when deploying the COBRA-compatible Hyperledger Fabric network, with clear solutions, root causes, and command references.

---

## 🛠️ Common Errors and Fixes

### ❌ `BAD_REQUEST` when creating channel

```
Error: got unexpected status: BAD_REQUEST -- error validating channel creation transaction for new channel 'channelcoop'...
error validating DeltaSet: policy for [Group] /Channel/Application not satisfied
```

**Cause:** The MSP environment variables do not match what's defined in `configtx.yaml`.

✅ **Solution:**

* Check the `CORE_PEER_MSPCONFIGPATH` in your terminal.
* Verify the `Admins` policy exists under `/Channel/Application`.
* Ensure the MSP ID matches the one defined in `Organizations:`.

---

### ❌ `panic: Failed validating bootstrap block`

```
Failed validating bootstrap block: cannot enable channel capabilities without orderer support first
```

**Cause:** Capabilities are defined but not enabled in the Orderer section of `configtx.yaml`.

✅ **Solution:**
Add these entries in `configtx.yaml`:

```yaml
Capabilities:
  Channel: &ChannelCapabilities
    V2_0: true
  Orderer: &OrdererCapabilities
    V2_0: true
  Application: &ApplicationCapabilities
    V2_0: true
```

Also ensure the `<<: *OrdererCapabilities` reference is correctly used.

---

### ❌ Orderer Org contains `endpoints` without V1.4.2+

```
Orderer Org OrderingService cannot contain endpoints value until V1_4_2+ capabilities have been enabled
```

**Cause:** Missing capabilities declaration.

✅ **Solution:** Add or correct capabilities section as shown above.

---

### ❌ `proposal failed: access denied: creator org unknown`

```
access denied: channel [] creator org unknown, creator is malformed
```

**Cause:** Environment variables (`CORE_PEER_MSPCONFIGPATH`, `CORE_PEER_LOCALMSPID`) are missing or incorrect.

✅ **Solution:**

* Check your CLI terminal environment variables.
* Use `docker exec` with `-e` flags for each variable.

---

### ❌ `failed to retrieve broadcast client: unable to load orderer.tls.rootcert.file`

```
open /etc/hyperledger/fabric/... no such file or directory
```

**Cause:** Incorrect or missing path to orderer TLS certificate.

✅ **Solution:**

```bash
export ORDERER_CA=/opt/gopath/fabric-samples/research-network/crypto-config/ordererOrganizations/research-network.com/orderers/orderer.research-network.com/msp/tlscacerts/tlsca.research-network.com-cert.pem
```

---

### ❌ `Discovery status Code: (11) UNKNOWN` when querying chaincode

```
failed constructing descriptor for chaincodes:<name:"test_4">
```

**Cause:** Smart contract name used in SDK does not match deployed chaincode.

✅ **Solution:**

* Check actual chaincode name with:

```bash
peer lifecycle chaincode querycommitted -C channelcoop
```

* Update your SDK or CLI call accordingly.

---

### ❌ `x509: certificate signed by unknown authority`

```
sanitizeCert failed the supplied identity is not valid
```

**Cause:** Using a Go version incompatible with Fabric's CA TLS handling.

✅ **Solution:**

* Downgrade to Go 1.17 or 1.18. Avoid 1.19+.

```bash
go version
```

---

## 🔁 Other Frequent Issues

### 🔄 Containers restart repeatedly

**Cause:** Misconfigured Docker volumes or environment files.

✅ **Solution:**

* Check volume paths.
* Validate `.env` and port usage.
* Use `docker logs <container>`.

### ⚠️ Peer cannot connect to orderer

**Cause:** Firewall rules, network segmentation, or wrong TLS.

✅ **Solution:**

* Ensure `--cafile` points to orderer's `tlsca` cert.
* Verify that `peerAddresses` and `tlsRootCertFiles` are set.

### 🧼 Cleanup fails due to lingering volumes

**Cause:** Docker keeps cryptographic volumes.

✅ **Solution:**

```bash
docker volume prune
docker network prune
```

---

## 🧪 Debugging Tools

| Command                                                  | Purpose                       |
| -------------------------------------------------------- | ----------------------------- |
| `docker ps -a`                                           | List all containers (up/down) |
| `docker logs <container>`                                | Inspect container output      |
| `peer lifecycle chaincode querycommitted -C channelcoop` | See active chaincode          |
| `peer channel list`                                      | List joined channels          |
| `peer channel getinfo -c channelcoop`                    | Inspect channel height        |

---

## 🧾 Tips for Stability

* Always open **one terminal per peer** during deployment.
* Set your environment variables **per peer** before invoking any CLI command.
* Match your `crypto-config.yaml`, `configtx.yaml`, and Docker files exactly.
* Document any modifications to avoid confusion in future deployments.
* Never mix MSP IDs (e.g., Provider1MSP vs. provider1MSP) — case matters.

---

## 🔗 See Also

* [Hyperledger Fabric documentation](https://hyperledger-fabric.readthedocs.io/en/latest/)
* [COBRA Framework GitHub](https://github.com/AxelOscar/Cobra-Framework)
