import rlp
from eth_hash.auto import keccak
from hexbytes import HexBytes

ZERO = "0x0000000000000000000000000000000000000000"


def get_create_address(addr, nonce):
    return "0x" + keccak(rlp.encode([HexBytes(addr), nonce]))[12:].hex()


def get_create2_address(addr, salt, initcode):
    salt = HexBytes(salt)
    assert len(salt) == 32
    return (
        "0x"
        + keccak(b"\xff" + HexBytes(addr) + salt + keccak(HexBytes(initcode)))[
            12:
        ].hex()
    )


def get_factory_create2_address(factory, salt, code, sender=ZERO):
    data = (
        HexBytes(b"\x00" * 12)
        + HexBytes(sender)
        + salt
        + HexBytes(b"\x00" * 31 + b"\x02")
    )
    assert len(data) == 32 * 3

    salt = keccak(data)
    return get_create2_address(factory, salt, code)


PROXY_CODE = bytes.fromhex("67363d3d37363d34f03d5260086018f3")


def get_factory_create3_address(factory, salt, sender=ZERO):
    data = (
        HexBytes(b"\x00" * 12)
        + HexBytes(sender)
        + salt
        + HexBytes(b"\x00" * 31 + b"\x03")
    )
    salt = keccak(data)
    proxy = get_create2_address(factory, salt, PROXY_CODE)
    return get_create_address(proxy, 1)
