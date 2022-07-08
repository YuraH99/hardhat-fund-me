const { network } = require("hardhat")
const {
    developmentChains,
    DECIMALS,
    INITIAL_ANSWER,
} = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    // after compiling the mock smart contract, we now have a contract that
    // can be used to deploy a fake price feed to the blockchain

    if (developmentChains.includes(network.name)) {
        // log is like console.log
        log("Local network detected! Deploying mocks...")
        await deploy("MockV3Aggregator", {
            from: deployer,
            log: true,
            args: [DECIMALS, INITIAL_ANSWER], // comes from the constructor of the mock contract
        })
        log("Mocks deployed.")
        log("--------------------------------------------------")
    }
}

module.exports.tags = ["all", "mocks"]
