import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const W3_DOAModule = buildModule("W3_DOAModule", (m) => {

    const erc20 = m.contract("W3_DOA");

    return { erc20 };
});

export default W3_DOAModule;

// W3_DOAModule#W3_DOA - 0x3F32f718505743708331D28c0A8eC5c4a822481B [Verified]