const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

// function deployFunc() {
//     console.log("Hi")
// }
// module.exports.default = deployFunc

// the two are identical, we just dont have a name for our async function below

// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre
// }

// below same as above

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    console.log(network.config)
    let ethUsdPriceFeedAddress // so that we can update it
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator") // with hardhat deploy, we can get the most recent deployment with .get
        // console.log(ethUsdAggregator)
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    // when going for localhost or hardhat network we want to use a mock
    // mock: mocking is creating objects that simulate the behavior of real objects.

    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, // args for the constructor
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log("------------------------------------")
}

module.exports.tags = ["all", "fundme"]

// yarn hardhat deploy -> 1. deploys mock aggregator if network name is hardhat (default)
// 2. if hardhat network, get address of mock aggregator smart contract, if else, get address of live/test network price feed contract
// 3. deploy fundme contract, passing in the price feed address
// yarn hardhat node -> when creating local node, we have our contracts on it. Thus, we can interact with them.
