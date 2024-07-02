import random
import time
from argparse import ArgumentParser

from eth_account import Account
from hexbytes import HexBytes

from .utils import (ZERO, get_create_address, get_factory_create2_address,
                    get_factory_create3_address)

PREFIX = [
    "0x00000000",
    "0x11111111",
    "0xffffffff",
    "0xeeeeeeee",
    "0x66666666",
    "0x88888888",
    "0xc0b00000"
]


def create0():
    acc = Account.create()
    addr = acc.address
    private_key = acc.privateKey
    contract = get_create_address(addr, 0)
    return (contract, f"{private_key.hex()} # {addr} nonce 0")


def create2(factory, sender, code):
    salt = random.randbytes(32)
    contract = get_factory_create2_address(factory, salt, code, sender)
    return (contract, f"{salt.hex()} # {sender} create2")


def create3(factory, sender):
    salt = random.randbytes(32)
    contract = get_factory_create3_address(factory, salt, sender)
    return (contract, f"{salt.hex()} # {sender} create3")


def bruteforce(rand_addr_func):
    i = 0
    start = time.time()
    try:
        with open("out.txt", "+a") as f:
            while True:
                i += 1

                if i % 100000 == 0:
                    end = time.time()
                    print(i, i / (end - start), "times/s             ", end="\r")

                contract, msg = rand_addr_func()

                for prefix in PREFIX:
                    if contract.startswith(prefix): 
                        text = f"{contract} {msg}\n"
                        print(text)
                        f.write(text)
                        f.flush()
    except KeyboardInterrupt:
        print("User stops.")


FACTORY = "0xC0B000003148E9c3E0D314f3dB327Ef03ADF8Ba7"


def main():
    parser = ArgumentParser(
        prog="vanity",
        description="A simple tool to generate vanity CoboFactory contract address.",
    )

    parser.add_argument(
        "-t",
        "--type",
        choices=["create", "create2", "create3"],
        required=True,
        help="Type to compute",
    )

    parser.add_argument(
        "-f", "--factory", default=FACTORY, help="Factory contract address."
    )

    parser.add_argument(
        "-s",
        "--sender",
        default=ZERO,
        help="The deployer address.",
    )

    parser.add_argument(
        "-c",
        "--code",
        help="The contract code.",
    )

    parser.add_argument("-p", "--prefix", nargs="+", default=[], help="The prefix code.")

    args = parser.parse_args()
    for p in args.prefix:
        if not p.startswith("0x"):
            p = '0x' + p
        p = p.lower()
        PREFIX.append(p)

    print("Prefix:", "\n  " + "\n  ".join(PREFIX))

    if args.type == "create":
        print("Create:")
        bruteforce(create0)
    elif args.type == "create2":
        assert args.code, "--code required"
        print("Create2:")
        print("  Factory:", args.factory)
        print("  Sender:", args.sender)
        print("  Code:", args.code[:30] + "...", len(HexBytes(args.code)), "bytes")
        bruteforce(lambda: create2(args.factory, args.sender, args.code))
    elif args.type == "create3":
        print("Create3:")
        print("  Factory:", args.factory)
        print("  Sender:", args.sender)
        bruteforce(lambda: create3(args.factory, args.sender))
    else:
        assert False


if __name__ == "__main__":
    main()
