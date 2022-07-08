const { getNamedAccounts, ethers } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Funding contract....")
    const txResponse = await fundMe.fund({
        value: ethers.utils.parseEther("0.07"),
    })
    await txResponse.wait(1)
    console.log("Funded!")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })

// interacting with hardhat node via scripts
// 1. yarn hardhat node (1st terminal)
// 2. yarn hardhat run scripts/fund.js --network localhost (2nd terminal)
