from web3 import Web3, HTTPProvider
import json

w3 = Web3(HTTPProvider('https://testnet-rpc.coinex.net'))

caller = "0x18E9a5eE2342C93f80036a6DD7A931Ebaf07BbC9"
private_key = "1dd3a5652ee5590dca9f6afef8340fab052a144c710505bd2341bb9387b3a23f"
nonce = w3.eth.getTransactionCount(caller)

address = "0x43aCb57b32E5bD2EC96741BEd9f047c860699566"
abi = json.load(open("/home/thanhtx/test/cronjob/abi.json", "r"))
contract = w3.eth.contract(address=address, abi=abi)

data = json.load(open("/home/thanhtx/test/data.json","r"))['data']
Chain_id = w3.eth.chain_id


call_function = contract.functions.rewardLPDelivery(
	[x['staker']['address'] for x in data],
	[int(float(x['percentage'])*10000) for x in data],
	len(data)
	).buildTransaction({"chainId": Chain_id, "from": caller, "nonce": nonce, "gasPrice": w3.eth.gas_price})

signed_tx = w3.eth.account.sign_transaction(call_function, private_key=private_key)
send_tx = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(send_tx)
print(tx_receipt)



