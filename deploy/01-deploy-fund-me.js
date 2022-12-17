const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethUsdPriceFeedAddres
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddres = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddres = networkConfig[chainId]["ethUsdPriceFeed"]
    }
    log("Deploying Fund Me")
    const args = [ethUsdPriceFeedAddres]
    const fundme = await deploy("FundMe", {
        contract: "FundMe",
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundme.address, args)
    }
    log("---------------------")
}

module.exports.tags = ["all", "FundMe"]
