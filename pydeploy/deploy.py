import json
import sys
import time
from argparse import ArgumentParser

from web3 import Web3


def main():
    parser = ArgumentParser(
        prog="deploy", description="Tool to deploy CoboFactory contract."
    )

    parser.add_argument(
        "-r",
        "--rpc-url",
        required=True,
        help="RPC URL which supports non EIP-155 transaction",
    )

    parser.add_argument(
        "-d",
        "--data",
        required=True,
        help="Json data file which contains pre-signed transactions",
    )

    args = parser.parse_args()

    file_name = args.data
    d = json.load(open(file_name))

    url = sys.argv[2]
    w3 = Web3(Web3.HTTPProvider(args.rpc_url))

    print("Chain id:", w3.eth.chain_id)

    contract = w3.to_checksum_address(d["contract"])
    deployer = w3.to_checksum_address(d["deployer"])
    unsigned_tx = d["unsignedTx"]
    txs = d["signedTxs"]

    print("Contract address:", contract)
    print("Deployer address:", deployer)

    code = w3.eth.get_code(contract)
    if len(code) != 0:
        print("Already deployed.")
        return

    nonce = w3.eth.get_transaction_count(deployer)
    if nonce != 0:
        print("Deployer nonce 0 used.")
        return

    gas = w3.eth.estimate_gas(unsigned_tx)
    print("Estimated gas:", gas)

    price_wei = w3.eth.gas_price
    print("Current gas price:", price_wei, f"({price_wei/1e9} Gwei)")

    found = False
    for tx in txs:
        if tx["gas"] > gas and tx["gasPrice"] > price_wei * 1.2:
            found = True
            break

    assert found, "Unable found transaction for the gas price and gas limit"
    print("Transaction found:")
    print("  Txid:", tx["txid"])
    print("  Gas limit:", tx["gasStr"])
    print("  Gas price:", tx["gasPriceStr"])

    eth_amount = tx["gas"] * tx["gasPrice"]

    while True:
        balance = w3.eth.get_balance(deployer)
        print(f"Current balance of deployer: {balance/1e18} ({balance} wei) ETH (Chain native token) ")

        if balance < eth_amount:
            print(
                f"Fund at least {eth_amount/1e18} ({eth_amount} wei) ETH (Chain native token) to {deployer}"
            )
            input("Press enter if the funding transaction is confirmed:")
        else:
            break

    raw_tx = tx["rawTx"]
    print("Sending raw transaction:")
    print(raw_tx)

    try:
        txid = w3.eth.send_raw_transaction(raw_tx)
        print("Txid", txid.hex())
    except Exception as e:
        if "EIP-155" in str(e):
            print(
                "Only replay-protected (EIP-155) transactions allowed over the RPC", url
            )
            print(
                "Change another RPC which supports non EIP-155 transaction. Find RPC in https://chainlist.org/"
            )
            return
        else:
            print("Error in sending transaction:")
            print(e)
            return

    print("Waiting receipt:")
    while True:
        try:
            time.sleep(1)
            rcpt = w3.eth.get_transaction_receipt(txid)
            break
        except Exception as e:
            print(e)
            pass

    assert rcpt.status == 1, "Transaction failed"
    print(f"Contract {rcpt.contractAddress} deployed.")


if __name__ == "__main__":
    main()
