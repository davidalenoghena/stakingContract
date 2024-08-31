import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x3F32f718505743708331D28c0A8eC5c4a822481B";

const ERC20_StakeModule = buildModule("ERC20_StakeModule", (m) => {

    const save = m.contract("ERC20_Stake", [tokenAddress]);

    return { save };
});

export default ERC20_StakeModule; 

// ERC20_StakeModule#ERC20_Stake - 0x67c483667db0f3401082f54C91B61CEA06c3d0F9 [Verified]
