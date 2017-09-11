const pay4doc = artifacts.require("PayForDoc")

module.exports = deployer => (
  deployer.deploy(pay4doc)
);
