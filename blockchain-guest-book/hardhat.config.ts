import "dotenv/config";
         import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
         import { defineConfig } from "hardhat/config";

         export default defineConfig({
                plugins: [hardhatToolboxMochaEthersPlugin],
                 solidity: {
                    version: "0.8.28",
                 },
                networks: {
                 sepolia: {
                    type: "http",
                    chainType: "l1",
                    url: process.env.SEPOLIA_RPC_URL!,
                    accounts: [process.env.SEPOLIA_PRIVATE_KEY!],
                },
               },
         });