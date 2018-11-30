var ConvertLib = artifacts.require("./ConvertLib.sol");
var TKU = artifacts.require("./TKU.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, TKU);
  deployer.deploy(TKU);
};
