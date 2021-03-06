#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Extract Token Balances
#
# Based on https://github.com/BitySA/whetcwithdraw/tree/master/daobalance
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# geth attach rpc:http://192.168.4.120:8545 << EOF
# geth attach rpc:http://localhost:8545 << EOF > oldTokenBalances.txt
geth attach << EOF > oldTokenBalances.txt

var D160 = new BigNumber("10000000000000000000000000000000000000000", 16);
var tokenAddress = "0x725803315519de78d232265a8f1040f054e70b98";
var tokenABI = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_amount","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"totalSupply","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"seal","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"acceptOwnership","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"data","type":"uint256[]"}],"name":"fill","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"newOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"tokenAddress","type":"address"},{"name":"amount","type":"uint256"}],"name":"transferAnyERC20Token","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"sealed","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}];
var token = web3.eth.contract(tokenABI).at(tokenAddress);
var fromBlock = 3947697;
// TEST var fromBlock = 4040064;
var toBlock = 4065064;
// var toBlock = parseInt(fromBlock) + 1000;
var block = eth.getBlock(toBlock);
console.log("BALANCE: snapshot at block=" + block.number + " time=" + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());

function getAccounts() {
  var accounts = {};
  var transferEventsFilter = token.Transfer({}, {fromBlock: fromBlock, toBlock: toBlock});
  var transferEvents = transferEventsFilter.get();
  for (var i = 0; i < transferEvents.length; i++) {
    var transferEvent = transferEvents[i];
    console.log(JSON.stringify(transferEvent));
    accounts[transferEvent.args._from] = 1;
    accounts[transferEvent.args._to] = 1;
  }
  return Object.keys(accounts);
}

function getBalancesAndCompress(accounts) {
    var balances = [];
    var totalBalance = new BigNumber(0);
    for (var i = 0; i < accounts.length; i++) {
        var account = accounts[i];
        var amount = token.balanceOf(account, toBlock);
        // Dao.Casino old multisig 
        if (account == "0x01dbb419d66be0d389fab88064493f1d698dc27a") {
            // Dao.Casino new multisig
            account = "0x1446bf7af9df857b23a725646d94f9ec49802227";
        }
        var addressNum = new BigNumber(account.substring(2), 16);
        var v = D160.mul(amount).add(addressNum);
        if (amount.greaterThan(0)) {
            balances.push(v.toString(10));
            totalBalance = totalBalance.add(amount);
            // if (i%100 === 0) console.log("Processed: " + i);
            console.log("BALANCE: " + i + "\t" + account + "\t" + amount.div(1e18) + "\t" + amount.toFixed(0));
        }
    }
    console.log("Total balance=" + totalBalance.toString(10));
    console.log("totalSupply=" + token.totalSupply().toString(10));
    return balances;
}

var accounts = getAccounts();
// console.log(JSON.stringify(accounts));
console.log("number of accounts, some may have a zero balances=" + accounts.length);
var balances = getBalancesAndCompress(accounts);
console.log("number of accounts+balances, only with non-zero balances=" + balances.length);
// console.log(JSON.stringify(balances, null, 2));
// console.log(JSON.stringify(balances));

var chunk = 80;
var balancesArray = [];
var numberOfItemsChunked = 0;
for (var i = 0; i < balances.length; i += chunk) {
    var balancesChunk = balances.slice(i, i+chunk);
    balancesArray.push(balancesChunk);
    numberOfItemsChunked += balancesChunk.length;
    // console.log("DATA: " + i + "\t" + JSON.stringify(balancesChunk, null));
}

console.log("number of accounts+balances, chunked=" + numberOfItemsChunked);
console.log("DATA: var data=" + JSON.stringify(balancesArray, null) + ";");

EOF

grep "BALANCE: " oldTokenBalances.txt | sed "s/BALANCE: //" > oldTokenBalancesByAccounts.txt
grep "DATA: " oldTokenBalances.txt | sed "s/DATA: //" > oldTokenBalancesData.js
