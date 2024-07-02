import json
import os
from argparse import ArgumentParser

from eth_account import Account

from .utils import get_create_address

path = os.path.join(
    os.path.dirname(__file__),
    "..",
    "solidity",
    "out",
    "CoboFactory.sol",
    "CoboFactory.json",
)

CALLDATA = json.load(open(path))["bytecode"]["object"]

tx = {
    # `type` is unset to use non EIP-155 tx
    # The deployer which can be bruteforced to get a vanity contract address.
    # "from": "TBD",
    # `to` is not set, means we are creating contract.
    # `data` is the creation code of factory contract
    "data": CALLDATA,
    # Default nonce and value
    "nonce": 0,
    "value": "0x0",
    # Default gas limit and gas price.
    # "gas": "TBD"
    # "gasPrice": "TBD"
}

gas_limit = [
    1_000_000,  # Should work on most EVM chains. 1/30 of ETH block gas limit (30M)
    3_000_000,  # 1/10 of ETH block gas limit (30M)
    10_000_000,  # Arbitrum
    10_000_000_000,  # Mantle sepolia  1/100 block gas limit (1000B)
    100_000_000_000,  # 1/10 of Mantle sepolia block gas limit (1000B)
    100_000_000_000_000,  # ~ 1/10 of Arbitrum block gas limit 0x4000000000000
]

gas_price_gwei = [
    0.1,  # Arbitrum
    5,  # BSC
    10,  # ETH
    15,
    30,
    50,
    70,
    100,  # Most EVM chains.
    200,
    400,
    800,
    8000,
    80000,
]

signed_txs = []


def add_to_signed_txs(tx, acc):
    signed_tx = acc.sign_transaction(tx)
    raw_tx = signed_tx.rawTransaction
    hash = signed_tx.hash
    signed_txs.append(
        {
            "gas": tx["gas"],
            "gasStr": "{:,.0f}".format(tx["gas"]),
            "gasPrice": tx["gasPrice"],
            "gasPriceStr": "%s gwei" % (tx["gasPrice"] / 1e9),
            "rawTx": raw_tx.hex(),
            "txid": hash.hex(),
        }
    )


def gen_signed_tx(priv_key):
    acc = Account.from_key(priv_key)
    from_addr = acc.address
    print("Deployer:", from_addr)

    contract = get_create_address(from_addr, 0)
    print("Contract:", contract)

    tx["from"] = from_addr
    d = {
        "contract": contract,
        "deployer": from_addr,
        "unsignedTx": dict(tx),
        "signedTxs": signed_txs,
    }
    for limit in gas_limit:
        for price in gas_price_gwei:
            gas_price_wei = int(price * 1e9)
            tx["gas"] = limit
            tx["gasPrice"] = gas_price_wei
            add_to_signed_txs(tx, acc)

    fp = open(f"{contract}_{from_addr}.json", "w")
    json.dump(d, fp, indent=4)
    print(f"{len(signed_txs)} txs signed.")


def main():
    parser = ArgumentParser(
        prog="gen-signed-tx", description="Generate pre-signed deployment transactions."
    )

    parser.add_argument(
        "-p", "--private-key", required=True, help="The private-key of deployer address"
    )

    args = parser.parse_args()
    gen_signed_tx(args.private_key)


if __name__ == "__main__":
    main()
