const {ethers} = require("hardhat");
const {CRYPTODEVS_NFT_CONTRACT_ADDRESS} = require("../constants"); // // importing the nft collection contract address

async function main() { // main function is the first function to run
const FakeNFTMarketplace = await ethers.getContractFactory("FakeNFTMarketplace"); //this is the contract that we are providing it some factory libraries to use. In other words it promises us to give it to us. In return to promise it provides us with an instance of the contract so that we can call the function  over it
const fakeNFTMarketplace = await FakeNFTMarketplace.deploy();
await fakeNFTMarketplace.deployed(); // this promises in return to deploy the contract and promises the contract to smoothly run the contract functions like mint and claim


console.log("FakeNFTMarketplace deployed to: ", fakeNFTMarketplace.address);//// this shows the address of the contract crypto devs

const CryptoDevsDAO = await ethers.getContractFactory("CryptoDevsDAO"); //this is the contract that we are providing it some factory libraries to use. In other words it promises us to give it to us. In return to promise it provides us with an instance of the contract so that we can call the function  over it
const cryptoDevsDAO = await CryptoDevsDAO.deploy(fakeNFTMarketplace.address, CRYPTODEVS_NFT_CONTRACT_ADDRESS,{value: ethers.utils.parseEther("0.1"), 
} //// This assumes your account has at least 1 ETH in it's account
);

await cryptoDevsDAO.deployed();

console.log("CryptoDevsDAO deployed to: ", cryptoDevsDAO.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});
