//
//  WalletBlockchainWrapperInteractor.swift
//  Essentia
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import Foundation
import EssentiaBridgesApi
import EssentiaNetworkCore
import HDWalletKit
import EssCore
import EssModel

fileprivate struct Constants {
    static var url = "https://b3.essentia.network"
    static var apiVersion = "/api/v1"
    static var serverUrl = url + apiVersion
    static var ethterScanApiKey = "IH2B5YWPTT3B19KMFYIFPMD85SQ7A12BDU"
}

class WalletBlockchainWrapperInteractor: WalletBlockchainWrapperInteractorInterface {
    private var cryptoWallet: CryptoWallet
    
    init() {
        cryptoWallet = CryptoWallet(bridgeApiUrl: Constants.serverUrl, etherScanApiKey: Constants.ethterScanApiKey)
    }
    
    func getCoinBalance(for coin: EssModel.Coin, address: String, balance: @escaping (Double) -> Void) {
        switch coin {
        case .bitcoin:
            cryptoWallet.bitcoin.getBalance(for: address) { (result) in
                switch result {
                case .success(let obect):
                    balance(obect.balance.value)
                default: return
                }
            }
        case .ethereum:
            cryptoWallet.ethereum.getBalance(for: address) { (result) in
                switch result {
                case .success(let obect):
                    balance(obect.balance.value)
                default: return
                }
            }
        case .bitcoinCash:
            cryptoWallet.bitcoinCash.getBalance(for: address) { (result) in
                switch result {
                case .success(let obect):
                    balance(obect.result)
                default: return
                }
            }
        case .litecoin:
            cryptoWallet.litecoin.getBalance(for: address) { (result) in
                switch result {
                case .success(let obect):
                    balance(obect.balance.value)
                default: return
                }
            }
        }
    }
    
    func getTokenBalance(for token: Token, address: String, balance: @escaping (Double) -> Void) {
        let erc20Token = ERC20(contractAddress: token.address, decimal: token.decimals, symbol: token.symbol)
        guard let data = try? erc20Token.generateGetBalanceParameter(toAddress: address) else {
            return
        }
        let smartContract = EthereumSmartContract(to: token.address, data: data.toHexString().addHexPrefix())
        cryptoWallet.ethereum.getTokenBalance(info: smartContract) { (result) in
            switch result {
            case .success(let object):
                guard let etherBalance = try? WeiEthterConverter.toToken(balance: object.balance, decimals: token.decimals, radix: 16) as NSDecimalNumber else {
                        return
                }
                balance(etherBalance.doubleValue)
            default: return
            }
        }
    }
    
    func getTokenTxHistory(address: Address, smartContract: Address, result: @escaping (NetworkResult<EthereumTokenTransactionByAddress>) -> Void) {
        cryptoWallet.ethereum.getTokenTxHistory(for: address, smartContract: smartContract, result: result)
    }
    
    func getTxHistoryForBitcoinAddress(_ address: String, result: @escaping (NetworkResult<BitcoinTransactionsHistory>) -> Void) {
        cryptoWallet.bitcoin.getTransactionsHistory(for: address, result: result)
    }
    
    func getTxHistoryForEthereumAddress(_ address: String, result: @escaping (NetworkResult<EthereumTransactionsByAddress>) -> Void) {
        cryptoWallet.ethereum.getTxHistory(for: address, result: result)
    }
    
    func getTxHistory(for token: Token, address: String, balance: @escaping (Double) -> Void) {
        
    }
    
    func getGasSpeed(prices: @escaping (Double, Double, Double) -> Void) {
        cryptoWallet.ethereum.getGasSpeed { (result) in
            switch result {
            case .success(let object):
                let gasPrices = object.result
                prices(gasPrices.safeLow, gasPrices.average, gasPrices.fast)
            default: return
            }
        }
    }
    
    func getEthGasPrice(gasPrice: @escaping (Double) -> Void) {
        cryptoWallet.ethereum.getGasPrice { (result) in
            switch result {
            case .success(let object):
                gasPrice(object.value)
            default: return
            }
        }
    }
    
    func getEthGasEstimate(fromAddress: String, toAddress: String, data: String, gasLimit: @escaping (Double) -> Void) {
        cryptoWallet.ethereum.getGasEstimate(from: fromAddress, to: toAddress, data: data) { (result) in
            switch result {
            case .failure(let error):
                (inject() as LoaderInterface).hide()
                print(error)
            case .success(let object):
                gasLimit(object.value)
            }
        }
    }
    
    func txRawParametrs(for asset: AssetInterface, toAddress: String, ammountInCrypto: String, data: Data) throws -> (value: Wei, address: String, data: Data) {
        switch asset {
        case let token as Token:
            let value = Wei(integerLiteral: 0)
            let erc20Token = ERC20(contractAddress: token.address, decimal: token.decimals, symbol: token.symbol)
            let data = try Data(hex: erc20Token.generateSendBalanceParameter(toAddress: toAddress,
                                                                    amount: ammountInCrypto).toHexString().addHexPrefix())
            return (value: value, token.address, data: data)
        case is EssModel.Coin:
            let value = try WeiEthterConverter.toWei(ether: ammountInCrypto)
            let data = data
            return (value: value, address: toAddress, data: data)
        default: throw EssentiaError.unexpectedBehavior
        }
    }
    
    func sendEthTransaction(wallet: ViewWalletInterface, transacionDetial: EtherTxInfo, result: @escaping (NetworkResult<String>) -> Void) throws {
        let txRwDetails = try txRawParametrs(for: wallet.asset,
                                             toAddress: transacionDetial.address,
                                             ammountInCrypto: transacionDetial.ammount.inCrypto,
                                             data: Data(hex: transacionDetial.data))
        let seed =  EssentiaStore.shared.currentCredentials.seed
        guard let pk = wallet.privateKey(withSeed: seed) else {
            throw EssentiaError.txError(.invalidPk)
        }
        let address = wallet.address(withSeed: seed)
        cryptoWallet.ethereum.getTransactionCount(for: address) { (transactionCountResult) in
            switch transactionCountResult {
            case .success(let count):
                let transaction = EthereumRawTransaction(value: txRwDetails.value,
                                                         to: txRwDetails.address,
                                                         gasPrice: transacionDetial.gasPrice,
                                                         gasLimit: transacionDetial.gasLimit,
                                                         nonce: count.count,
                                                         data: txRwDetails.data)
                let dataPk = Data(hex: pk)
                let signer = EIP155Signer.init(chainId: 1)
                guard let txData = try? signer.sign(transaction, privateKey: dataPk) else {
                    result(.failure(.unknownError))
                    return
                }
                self.cryptoWallet.ethereum.sendTransaction(with: txData.toHexString().addHexPrefix(), result: {
                    switch $0 {
                    case .success(let object):
                        result(.success(object.txId))
                    case .failure(let error):
                        result(.failure(error))
                    }
                })
            default:
                result(.failure(.unknownError))
            }
            
        }
    }
}
