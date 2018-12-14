var Dlogs = artifacts.require("./Dlogs.sol");

module.exports = function(deployer) {
  deployer.deploy(Dlogs, "0x1b366458dceb0707a54b384a2c801d6df02cbec9");
};
