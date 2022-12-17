const { run } = require("hardhat")

async function verify(contractAdderess, args) {
    console.log("Verifying contract ...")
    try {
        await run("verify:verify", {
            address: contractAdderess,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified")
        } else {
            console.log(e)
        }
    }
}

module.exports = {
    verify,
}
