require("dotenv").config();

const fs = require("fs");
const solc = require("solc");
const { ethers } = require("ethers");

async function main() {
  const source = fs.readFileSync("contracts/USDTSettlement.sol", "utf8");

  const input = {
    language: "Solidity",
    sources: { "USDTSettlement.sol": { content: source } },
    settings: {
      optimizer: { enabled: true, runs: 200 },
      outputSelection: { "*": { "*": ["abi", "evm.bytecode"] } }
    }
  };

  const output = JSON.parse(solc.compile(JSON.stringify(input)));

  if (output.errors) {
    for (const e of output.errors) console.log(e.formattedMessage);
    if (output.errors.some(e => e.severity === "error")) {
      throw new Error("Erro na compilacao");
    }
  }

  const data = output.contracts["USDTSettlement.sol"]["USDTSettlement"];

  const provider = new ethers.providers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  const balance = await provider.getBalance(wallet.address);

  console.log("Carteira:", wallet.address);
  console.log("Saldo Sepolia:", ethers.utils.formatEther(balance), "ETH");

  if (balance.eq(0)) {
    throw new Error("Carteira sem Sepolia ETH para pagar gas.");
  }

  const factory = new ethers.ContractFactory(
    data.abi,
    "0x" + data.evm.bytecode.object,
    wallet
  );

  const supply = ethers.BigNumber.from("77595196000000");

  console.log("Fazendo deploy...");
  const contract = await factory.deploy(supply, wallet.address);

  console.log("TX HASH:", contract.deployTransaction.hash);

  await contract.deployTransaction.wait(1);

  console.log("CONTRATO DEPLOYADO:", contract.address);
}

main().catch((err) => {
  console.log("ERRO LIMPO:");
  console.log(err.reason || err.message || err);
});
