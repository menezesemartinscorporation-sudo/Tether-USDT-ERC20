require('@nomiclabs/hardhat-ethers');
require('dotenv').config();

async function main() {
    const { ethers } = require('ethers');
    const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const data = require('./SDTSettlement.json'); // Supondo que você tem o JSON do ABI e do bytecode
    console.log("Carteira:", wallet.address);
    const balance = await provider.getBalance(wallet.address);
    console.log("Saldo Sepolia:", ethers.utils.formatEther(balance), "ETH");

    if (balance.eq(0)) {
        throw new Error("Carteira sem Sepolia ETH para pagar gas.");
    }

    const factory = new ethers.ContractFactory(
        data.abi,
        "0x" + data.evm.bytecode.object,
        wallet
    );

    const supply = ethers.BigNumber.from("7759519600");

    console.log("Fazendo deploy...");
    const contract = await factory.deploy(supply, wallet.address);

    console.log("TX
