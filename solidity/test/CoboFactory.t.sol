// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CoboFactory} from "../src/CoboFactory.sol";

contract FactoryTest is Test {
    CoboFactory public factory;
    address constant ZERO = address(0);

    event ContractDeployed(
        address indexed _contract,
        address indexed _deployer
    );

    function setUp() public {
        factory = new CoboFactory();
    }

    function test_FactoryNoEmit() public {
        bytes
            memory code = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

        bytes32 salt = bytes32(uint256(1));
        address deployer = address(this);


        console.log("factory:", address(factory));
        console.log("deployer:", deployer);
        assertEq(deployer, 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);

        address addr = factory.deploy(
            CoboFactory.DeployType.Create2,
            salt,
            code
        );

        console.log("create2:", addr);
        assertEq(addr, 0xa8Bb576923198bbc6C66267d8900CF3b69c0472D);
 
        assertEq(
            addr,
            factory.getAddress(CoboFactory.DeployType.Create2, salt, ZERO, code)
        );
        assertEq(addr, factory.getCreate2Address(salt, ZERO, code));

        addr = factory.deploy(CoboFactory.DeployType.Create3, salt, code);
        console.log("create3:", addr);
        assertEq(addr, 0x213e6FfF3a309E28EA856F04439eaf24e8a2fa14);
 
        assertEq(
            addr,
            factory.getAddress(CoboFactory.DeployType.Create3, salt, ZERO, "")
        );
        assertEq(addr, factory.getCreate3Address(salt, ZERO));

        addr = factory.deploy(
            CoboFactory.DeployType.Create2WithSender,
            salt,
            code
        );
        console.log("create2withsender:", addr);
        assertEq(addr, 0xE6500D723480e95c6B4766bDAe759cDf47BDcC83);
 
        assertEq(
            addr,
            factory.getAddress(
                CoboFactory.DeployType.Create2WithSender,
                salt,
                deployer,
                code
            )
        );
        assertEq(addr, factory.getCreate2Address(salt, deployer, code));

        addr = factory.deploy(
            CoboFactory.DeployType.Create3WithSender,
            salt,
            code
        );
        console.log("create3withsender:", addr);
        assertEq(addr, 0x95969B73f37da84E7681d770f5fF563046000fa9);
 
        assertEq(
            addr,
            factory.getAddress(
                CoboFactory.DeployType.Create3WithSender,
                salt,
                deployer,
                ""
            )
        );
        assertEq(addr, factory.getCreate3Address(salt, deployer));

        vm.expectRevert("Create3 proxy failed");
        factory.deploy(CoboFactory.DeployType.Create3WithSender, salt, code);
    }

    function test_FactoryEmit() public {
        bytes
            memory code = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

        bytes32 salt = bytes32(uint256(1));
        address deployer = address(this);


        address factoryAddress = address(factory);

        console.log("factory:", factoryAddress);
        console.log("deployer:", deployer);
        assertEq(deployer, 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);

        vm.expectEmit(true, true, false, false, factoryAddress);
        emit ContractDeployed(0xa8Bb576923198bbc6C66267d8900CF3b69c0472D, deployer);
        
        address addr = factory.deploy(
            CoboFactory.DeployType.Create2AndEmit,
            salt,
            code
        );

        console.log("create2:", addr);
        assertEq(addr, 0xa8Bb576923198bbc6C66267d8900CF3b69c0472D);
 
        assertEq(
            addr,
            factory.getAddress(CoboFactory.DeployType.Create2AndEmit, salt, ZERO, code)
        );
        assertEq(addr, factory.getCreate2Address(salt, ZERO, code));


        vm.expectEmit(true, true, false, false, factoryAddress);
        emit ContractDeployed(0x213e6FfF3a309E28EA856F04439eaf24e8a2fa14, deployer);
        
        addr = factory.deploy(CoboFactory.DeployType.Create3AndEmit, salt, code);
        console.log("create3:", addr);
        assertEq(addr, 0x213e6FfF3a309E28EA856F04439eaf24e8a2fa14);
 
        assertEq(
            addr,
            factory.getAddress(CoboFactory.DeployType.Create3AndEmit, salt, ZERO, "")
        );
        assertEq(addr, factory.getCreate3Address(salt, ZERO));

        vm.expectEmit(true, true, false, false, factoryAddress);
        emit ContractDeployed(0xE6500D723480e95c6B4766bDAe759cDf47BDcC83, deployer);
        
        addr = factory.deploy(
            CoboFactory.DeployType.Create2WithSenderAndEmit,
            salt,
            code
        );
        console.log("create2withsender:", addr);
        assertEq(addr, 0xE6500D723480e95c6B4766bDAe759cDf47BDcC83);
 
        assertEq(
            addr,
            factory.getAddress(
                CoboFactory.DeployType.Create2WithSenderAndEmit,
                salt,
                deployer,
                code
            )
        );
        assertEq(addr, factory.getCreate2Address(salt, deployer, code));

        vm.expectEmit(true, true, false, false, factoryAddress);
        emit ContractDeployed(0x95969B73f37da84E7681d770f5fF563046000fa9, deployer);
        
        addr = factory.deploy(
            CoboFactory.DeployType.Create3WithSenderAndEmit,
            salt,
            code
        );
        console.log("create3withsender:", addr);
        assertEq(addr, 0x95969B73f37da84E7681d770f5fF563046000fa9);
 
        assertEq(
            addr,
            factory.getAddress(
                CoboFactory.DeployType.Create3WithSenderAndEmit,
                salt,
                deployer,
                ""
            )
        );
        assertEq(addr, factory.getCreate3Address(salt, deployer));

        vm.expectRevert("Create3 proxy failed");
        factory.deploy(CoboFactory.DeployType.Create3WithSenderAndEmit, salt, code);
    }
}
