var ConvertLib = artifacts.require("./ConvertLib.sol");
var Dlogs = artifacts.require("./Dlogs.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, Dlogs);
  deployer.deploy(Dlogs, "0x3c8bcc1314039b2870cebecc48cf3953bf004ff6");
};
