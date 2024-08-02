# CoboFactory

A permissionless universal EVM-chain contract factory supporting create2 and create3 deployment.

# Usage

## Deployment

The CoboFactory is already deployed at 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 on the chains below.

Mainnet:
- [Ethereum](https://etherscan.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Polygon](https://polygonscan.com/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Arbitrum](https://arbiscan.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Optimism](https://optimistic.etherscan.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Avalanche](https://snowtrace.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7/contract/43114/code)
- [Base](https://basescan.org/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [BSC](https://bscscan.com/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Mode](https://explorer.mode.network/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7?tab=contract)
- [Mantle](https://explorer.mantle.xyz/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7?tab=contract)
- [Gnosis](https://gnosisscan.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)
- [Manta](https://manta.socialscan.io/address/0xc0b000003148e9c3e0d314f3db327ef03adf8ba7#contract)
- [Scroll](https://scrollscan.com/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)

Testnet:
- [Ethereum Sepolia Testnet](https://sepolia.etherscan.io/address/0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7#code)

## Deploy the factory contract with pre-signed transaction

Everyone can deploy the same CoboFactory contract at the same address accross different EVM chains, if not deployed before.

Run `python -m pydeploy.deploy` and fund the deployer enough gas.

> Note: Select a RPC endpoint that supports Non-[EIP 155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) transaction.

```sh
$ python -m pydeploy.deploy -r https://rpc-sepolia.rockx.com -d pre-signed.json 
Chain id: 11155111
Contract address: 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7
Deployer address: 0xdD76529AE31B931c85D2a39df0a6807c538b0c4a
Estimated gas: 697398
Current gas price: 15090378285 (15.090378285 Gwei)
Transaction found:
  Txid: 0xd5745f6cb658ab9b7bf66c52d83c9b134cb03a755a9301d78142bdd3bc062d40
  Gas limit: 1,000,000
  Gas price: 30.0 gwei
Current balance of deployer: 0.0 ETH (0 wei)
Fund at least 0.03 ETH (30000000000000000 wei) to 0xdD76529AE31B931c85D2a39df0a6807c538b0c4a
Press enter if the funding transaction is confirmed:
Current balance of deployer: 0.03 ETH (30000000000000000 wei)
Sending raw transaction:
0xf90c0..48a30c9da2
Txid 0xd5745f6cb658ab9b7bf66c52d83c9b134cb03a755a9301d78142bdd3bc062d40
Waiting receipt:
Transaction with hash: '0xd5745f6cb658ab9b7bf66c52d83c9b134cb03a755a9301d78142bdd3bc062d40' not found.
Transaction with hash: '0xd5745f6cb658ab9b7bf66c52d83c9b134cb03a755a9301d78142bdd3bc062d40' not found.
Contract 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 deployed.
```


## Verify the contract

1. Use forge.
```sh
$ cd solidity
$ ETHERSCAN_API_KEY=<your-api-key> forge verify-contract 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 CoboFactory --chain sepolia
```

2. Use [Etherscan web UI](https://etherscan.io/verifyContract). 
- Compiler Type: `Solidity (Standard-Json-Input)`
- Compiler Version: `v0.8.20+commit.a1b79de6`
- Open Source License Type: `GNU Lesser General Public License v3.0 (GNU LGPLv3)`
- Update [standard-json-input.json](./standard-json-input.json)

## Generate your own pre-signed transactions

```sh
# Clone the repo.
$ git clone --recursive https://github.com/coboglobal/cobo-factory

# Compile the contract
$ cd solidity
$ forge test

# Generate the pre-signed txs data file.
$ cd ..
$ python -m pydeploy.gen_signed_tx -p 0xdeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeaddeadbeaf
```

## Compute vanity address

```sh
# Compute the factory deployer address.
$ python -m pydeploy.vanity -t create

# Compute the factory salt
$ python -m pydeploy.vanity -t create2 -f 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 -c 0x6080<your-code> -p 0x1234
$ python -m pydeploy.vanity -t create2 -f 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 -s 0x<your-address> -c 0x6080<your-code>

$ python -m pydeploy.vanity -t create3 -f 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7
$ python -m pydeploy.vanity -t create2 -f 0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7 -s 0x<your-address>
```

## Use the factory

```solidity

interface ICoboFactory {
    enum DeployType {
        Create2,
        Create3,
        Create2WithSender,
        Create3WithSender,
        Create2AndEmit,
        Create3AndEmit,
        Create2WithSenderAndEmit,
        Create3WithSenderAndEmit
    }
    function deploy(
        DeployType typ,
        bytes32 salt,
        bytes memory initCode
    ) external returns (address);

    function getAddress(
        DeployType typ,
        bytes32 salt,
        address sender,
        bytes calldata initCode
    ) external view returns (address _contract);
}

contract A {
    address public a;
    constructor(address _a) {
        a = _a;
    }
}

contract DeployTest {

    function doDeploy() public {
        ICoboFactory factory = ICoboFactory(0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7);
        
        bytes memory initCode = abi.encodePacked(
              type(A).creationCode,
              abi.encode(address(1))
        );
        bytes32 salt = "Cobo";
        address _contract = factory.deploy(
            ICoboFactory.DeployType.Create2,
            salt,
            initCode
        );
    }
}
```