// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.20;

/**
 * @title Cobo Factory Smart Contract
 * @author https://github.com/coboglobal
 * @dev Inspired by https://github.com/pcaversaccio/createx
 */
contract CoboFactory {
    
    event ContractDeployed(
        address indexed _contract,
        address indexed _deployer
    );

    uint256 constant CREATE3_BIT = 0x1; 
    uint256 constant WITH_SENDER_BIT = 0x2;
    uint256 constant EMIT_EVENT_BIT = 0x4;

    uint256 constant CREATE2_TAG = 2;
    uint256 constant CREATE3_TAG = 3;

    enum DeployType {
        Create2,                  // None = 0
        Create3,                  // CREATE3_BIT = 1
        Create2WithSender,        // WITH_SENDER_BIT = 2
        Create3WithSender,        // CREATE3_BIT | WITH_SENDER_BIT = 3
        Create2AndEmit,           // EMIT_EVENT_BIT = 4
        Create3AndEmit,           // CREATE3_BIT | EMIT_EVENT_BIT = 5
        Create2WithSenderAndEmit, // WITH_SENDER_BIT | EMIT_EVENT_BIT = 6
        Create3WithSenderAndEmit  // CREATE3_BIT | WITH_SENDER_BIT | EMIT_EVENT_BIT = 7
    }

    function _guardSalt(
        address sender,
        bytes32 salt,
        uint256 tag
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(sender, salt, tag));
    }

    function deployCreate2(
        bytes32 salt,
        bytes memory initCode,
        bool _private,
        bool _emit
    ) public returns (address _contract) {
        address sender = _private ? msg.sender : address(0);
        salt = _guardSalt(sender, salt, CREATE2_TAG);
        assembly {
            _contract := create2(0, add(initCode, 0x20), mload(initCode), salt)
        }
        require(_contract != address(0), "Create2 failed");
        if (_emit){
            emit ContractDeployed(_contract, msg.sender);
        }
    }

    function deployCreate3(
        bytes32 salt,
        bytes memory initCode,
        bool _private,
        bool _emit
    ) public returns (address _contract) {
        address sender = _private ? msg.sender : address(0);
        bytes32 finalSalt = _guardSalt(sender, salt, CREATE3_TAG);
        bytes
            memory proxyChildBytecode = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";
        address proxy;
        assembly {
            proxy := create2(
                0,
                add(proxyChildBytecode, 32),
                mload(proxyChildBytecode),
                finalSalt
            )
        }
        require(proxy != address(0), "Create3 proxy failed");

        (bool success, bytes memory _retData) = proxy.call(initCode);
        if (!success) {
            assembly {
                let size := mload(_retData)
                revert(add(32, _retData), size)
            }
        }
        _contract = getCreate3Address(salt, sender);
        require(_contract.code.length > 0, "Create3 failed");
        if (_emit){
            emit ContractDeployed(_contract, msg.sender);
        }
    }

    function deploy(
        DeployType typ,
        bytes32 salt,
        bytes memory initCode
    ) public returns (address _contract) {
        uint256 typeBits = uint256(typ);
        bool create3 = typeBits & CREATE3_BIT == CREATE3_BIT;
        bool withSender = typeBits & WITH_SENDER_BIT == WITH_SENDER_BIT;
        bool emitEvent = typeBits & EMIT_EVENT_BIT == EMIT_EVENT_BIT;

        if(create3){
            return deployCreate3(salt, initCode, withSender, emitEvent);
        }else{
            return deployCreate2(salt, initCode, withSender, emitEvent);
        }
    }

    function deployAndInit(
        DeployType typ,
        bytes32 salt,
        bytes calldata initCode,
        bytes calldata callData
    ) public returns (address _contract) {
        _contract = deploy(typ, salt, initCode);
        (bool success, bytes memory _retData) = _contract.call(callData);
        if (!success) {
            assembly {
                let size := mload(_retData)
                revert(add(32, _retData), size)
            }
        }
    }

    function getCreate2Address(
        bytes32 salt,
        address sender,
        bytes calldata initCode
    ) public view returns (address _contract) {
        bytes32 initCodeHash = keccak256(initCode);
        address deployer = address(this);
        salt = _guardSalt(sender, salt, CREATE2_TAG);
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), initCodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer)
            let start := add(ptr, 0x0b)
            mstore8(start, 0xff)
            _contract := keccak256(start, 85)
        }
    }

    function getCreate3Address(
        bytes32 salt,
        address sender
    ) public view returns (address _contract) {
        address deployer = address(this);
        salt = _guardSalt(sender, salt, CREATE3_TAG);
        assembly {
            let ptr := mload(0x40)
            mstore(0x00, deployer)
            mstore8(0x0b, 0xff)
            mstore(0x20, salt)
            mstore(
                0x40,
                hex"21_c3_5d_be_1b_34_4a_24_88_cf_33_21_d6_ce_54_2f_8e_9f_30_55_44_ff_09_e4_99_3a_62_31_9a_49_7c_1f"
            )
            mstore(0x14, keccak256(0x0b, 0x55))
            mstore(0x40, ptr)
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01)
            _contract := keccak256(0x1e, 0x17)
        }
    }

    function getAddress(
        DeployType typ,
        bytes32 salt,
        address sender,
        bytes calldata initCode
    ) external view returns (address _contract) {
        typ = DeployType(uint256(typ) & (CREATE3_BIT | WITH_SENDER_BIT));
        if (typ == DeployType.Create2) {
            _contract = getCreate2Address(salt, address(0), initCode);
        } else if (typ == DeployType.Create2WithSender) {
            _contract = getCreate2Address(salt, sender, initCode);
        } else if (typ == DeployType.Create3) {
            _contract = getCreate3Address(salt, address(0));
        } else if (typ == DeployType.Create3WithSender) {
            _contract = getCreate3Address(salt, sender);
        }
    }
}
