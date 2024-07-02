// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

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

contract DeployTest is Test {

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/eth");
    }

    function test_FactoryDeploy() public {
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
        assertEq(_contract, factory.getAddress(
            ICoboFactory.DeployType.Create2,
            salt,
            address(this),
            initCode
        ));

        assertEq(A(_contract).a(), address(1));
    }
}
