# xapp-starter

Starter kit for cross-domain apps (xApps).
# Overview

With Connext's upgraded protocol, there are generally three types of bridging transactions that can be executed fully through smart contract integration.
- Simple transfers
- Unpermissioned calls
- Permissioned calls

This starter repo contains contracts that demonstrate how to use each type of transaction.

<img src="documentation/assets/xcall.png" alt="drawing" width="500"/>

## XDomainTransfer

Simple transfer from Sending Chain to Receiving Chain. Does not use calldata. 

Example use cases:
- Send funds across chains

Contracts:
- XDomainTransfer.sol

## XDomainUnpermissioned

Transfer funds and/or call a target contract with arbitrary calldata on the Receiving Chain. Assuming the receiving side is a unpermissioned call, this flow is essentially the same as a simple transfer except encoded calldata is included in the `xcall`. The call can simply use `amount: 0` if no transfer is required.

Example use cases:
- Deposit funds into a liquidity pool on the Receiving Chain
- Execute a token Swap on the Receiving Chain
- Connecting DEX liquidity across chains in a single seamless transaction
- Crosschain vault zaps and vault strategy management

Contracts:
- XDomainUnpermissioned.sol
- UnpermissionedTarget.sol

## XDomainPermissioned

Like unpermissioned, call a target contract with arbitrary calldata on the Receiving Chain. Except, the target function is permissioned which means the contract owner must make sure to check the origin in order to uphold permissioning requirements.

Example use cases:
- Hold a governance vote on Sending Chain and execute the outcome of it on the Receiving Chain (and other DAO operations)
- Lock-and-mint or burn-and-mint token bridging
- Critical protocol operations such as replicating/syncing global constants (e.g. PCV) across chains
- Bringing UniV3 TWAPs to every chain without introducing oracles
- Chain-agnostic veToken governance
- Metaverse-to-metaverse interoperability

Contracts:
- XDomainPermissioned.sol
- PermissionedTarget.sol

# Development

## Getting Started

This project uses Foundry for testing and deploying contracts. Hardhat tasks are used for interacting with deployed contracts.

- See the official Foundry installation [instructions](https://github.com/gakonst/foundry/blob/master/README.md#installation).
- [Forge template](https://github.com/abigger87/femplate) by abigger87.

## Blueprint

```ml
src
├─ contract-to-contract-interactions
|  └─ transfer
│    └─ XDomainTransfer.sol — "XDomainTransfer Contract"
|  └─ unpermissioned
│    └─ XDomainUnpermissioned.sol — "XDomainUnpermissioned Contract"
│    └─ UnpermissionedTarget.sol — "Target Contract"
|  └─ permissioned
│    └─ XDomainPermissioned.sol — "XDomainPermissioned Contract"
│    └─ PermissionedTarget.sol — "Target Contract"
|  └─ tests
│    └─ ...
├─ sdk-interactions
│    └─ ...
```
## Setup
```bash
make install
```

## Testing

### Unit Tests

```bash
make test-unit-all
make test-unit-transfer
make test-unit-unpermissioned
make test-unit-permissioned
```

### Integration Tests

This uses forge's `--forked` mode. Make sure you have `TESTNET_RPC_URL` defined in your `.env` file. Currently, the test cases are pointed at Connext's Kovan testnet deployments.
```bash
make test-forked-transfer
make test-forked-unpermissioned
make test-forked-permissioned
```

### Deployment

This command will allow you to deploy contracts in this repository using the RPC provider of your choice.

```bash
forge create <path/to/contract:contractName> -i --rpc-url <rpc_url> --constructor-args <space separated args>
```

- Deployment order for Simple Transfer 

    ```bash
    forge create src/contract-to-contract-interactions/transfer/XDomainTransfer.sol:XDomainTransfer -i --rpc-url <source_chain_rpc> --constructor-args <address(ConnextHandler)>
    ```

- Deployment order for Unpermissioned Deposit

    ```bash
    forge create src/contract-to-contract-interactions/unpermissioned/XDomainUnpermissioned.sol:XDomainUnpermissioned -i --rpc-url <source_chain_rpc> --constructor-args <address(ConnextHandler)>
    ```

    ```bash
    forge create src/contract-to-contract-interactions/unpermissioned/UnpermissionedTarget.sol:UnpermissionedTarget -i --rpc-url <destination_chain_rpc>
    ```

- Deployment order for Permissioned Update

    ```bash
    forge create src/contract-to-contract-interactions/permissioned/XDomainPermissioned.sol:XDomainPermissioned -i --rpc-url <source_chain_rpc> --constructor-args <address(ConnextHandler)>
    ```
    
    ```bash
    forge create src/contract-to-contract-interactions/permissioned/PermissionedTarget.sol:PermissionedTarget -i --rpc-url <destination_chain_rpc> --constructor-args <address(XDomainPermissioned)> <origin_domainID> <address(ConnextHandler)> 
    ```

### Verification

Use the `forge verify-contract` command. 
- compiler version should be specified in "v.X.Y.Z+commit.xxxxxxxx" format, a list of versions can be found [here](https://etherscan.io/solcversions)
- see [Chainlist](https://chainlist.org/) for chain-id
- constructor arguments must be in ABI-encoded format
  - tip: can be found as the last 64*N characters of the "Input Data" used in the Contract Creation transaction, where N is the number of constructor arguments

    Ex: 3 constructor arguments used
    ```bash
    echo -n <input_data> | tail -c 192
    ```

```bash
forge verify-contract --compiler-version <solc_version> <address(contract)> <path_to_contract_src> <etherscan_api_key> --chain-id <chain_id> --constructor-args <encoded_constructor_args>
```

### Live Testnet Testing

The core set of Connext + Nomad contracts have already been deployed to testnet. For the most up-to-date contracts, please reference the [Connext deployments](https://github.com/connext/nxtp/tree/main/packages/deployments/contracts/deployments).

There is a set of Hardhat tasks available for executing transactions on deployed contracts.

- Execute Simple Transfer

  ```bash
  yarn hardhat transfer --origin-domain <domainID> --destination-domain <domainID> --contract-address <XDomainTransfer> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key> --amount <amount>
  ```

- Execute Unpermissioned Deposit

  ```bash
  yarn hardhat deposit --origin-domain <domainID> --destination-domain <domainID> --contract-address <address(XDomainUnpermissioned)> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key> --amount <amount>
  ```

- Execute Permissioned Update

  ```bash
  yarn hardhat update --origin-domain <domainID> --destination-domain <domainID> --contract-address <address(XDomainPermissioned)> --middleware-address <address(PermissionedTarget)> --token-address <address(origin_TestERC20)> --wallet-address <your_wallet_address> --wallet-private-key <your_private_key>
  ```
