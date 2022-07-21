const Web3 = require('web3');
const NFTContract = require('./build/contracts/NFT.json');
const address = '0x7864dddf2FF4bF04C66482993b497A7bD19C7Bdc';
const privateKey =
  'cdf1d2868e6d5757c280079ea70ef7d7e23b969561c253c5a9cd75d278abafbc';
const infuraUrl =
  'https://rinkeby.infura.io/v3/4ba90a9a0bf947a289cf1a0c56c15e7f';
const init1 = async () => {
  const web3 = new Web3(infuraUrl);
  const networkId = await web3.eth.net.getId();
  const nftContract = new web3.eth.Contract(
    NFTContract.abi,
    NFTContract.networks[networkId].address
  );
  const tx = nftContract.methods.enternum(5);
  const gas = await tx.estimateGas({ from: address });
  const gasPrice = await web3.eth.getGasPrice();
  const data = tx.encodeABI();
  const nonce = await web3.eth.getTransactionCount(address);
  const signedTx = await web3.eth.accounts.signTransaction(
    {
      to: nftContract.options.address,
      data,
      gas,
      gasPrice,
      nonce,
      chainId: networkId,
    },
    privateKey
  );

  console.log(`Old data value: ${await nftContract.methods.mynumber().call()}`);
  const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
  console.log(`Transaction Hash: ${receipt.transactionHash}`);
  console.log(`New Data Value: ${await nftContract.methods.mynumber().call()}`);
};
init1();
