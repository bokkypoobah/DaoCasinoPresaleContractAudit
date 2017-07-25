#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Send token balance data
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

geth attach rpc:http://localhost:9545 << EOF | tee sendDataTransaction.txt

loadScript("oldTokenBalancesData.js");

var newTokenAbi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_amount","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"seal","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"acceptOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"data","type":"uint256[]"}],"name":"fill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"newOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"tokenAddress","type":"address"},{"name":"amount","type":"uint256"}],"name":"transferAnyERC20Token","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"sealed","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var newTokenAddress = "0x758ecc3cf1ab1dec176863df71bda87fd482ec2f";
var newToken = eth.contract(newTokenAbi).at(newTokenAddress);
var account = eth.accounts[1];

for (var i = 0; i < data.length; i++) {
    console.log("Sending " + (i + 1) + " of " + data.length + " " + JSON.stringify(data[i]));
    var txId = newToken.fill(data[i], {from: account, gas: 700000, gasPrice: web3.toWei(20, "gwei")});
    console.log("  txId=" + txId); 
    while (eth.getTransactionReceipt(txId) == null) {
    }
    console.log("  tx=" + eth.getTransactionReceipt(txId));
    var tx = eth.getTransaction(txId);
    var txReceipt = eth.getTransactionReceipt(txId);
    var gasPrice = tx.gasPrice;
    var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
    console.log("GAS: " + gasCostETH);
}
var txId = newToken.seal({from: account, gas: 700000, gasPrice: web3.toWei(20, "gwei")});
console.log("  txId=" + txId); 
while (eth.getTransactionReceipt(txId) == null) {
}
console.log("  tx=" + eth.getTransactionReceipt(txId));
var tx = eth.getTransaction(txId);
var txReceipt = eth.getTransactionReceipt(txId);
var gasPrice = tx.gasPrice;
var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
console.log("GAS: " + gasCostETH);

EOF
