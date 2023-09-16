//
//  ViewController.swift
//  Kriptonian
//
//  Created by Pavel Shabliy on 14.09.2023.
//

import UIKit
import HdWalletKit
import BitcoinKit
import BitcoinCore
import HsToolKit

class ViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var sendField: UITextField!
    
    @IBOutlet weak var replenishmentAddress: UILabel!
    @IBOutlet weak var wallet: UILabel!
   
    var bitcoinKit: BitcoinKit.Kit?
    
    let words = ["annual",
                 "sword",
                 "uncle",
                 "unknown",
                 "remove",
                 "decline",
                 "plate",
                 "dust",
                 "choose",
                 "major",
                 "soul",
                 "clever"]

    let passphrase: String = "sabliyrulit95"
    
    let walletId: String = "MySoUniqueIdForWallet"
    
    let logger: Logger = .init(minLogLevel: .verbose)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBitcoinKit()
    }
    
    @IBAction func updateBalance(_ sender: Any) {
        wallet.text = String(describing: bitcoinKit?.balance)
    }
    @IBAction func sendButton(_ sender: Any) {
           if let toAddress = addressField.text, let valueText = sendField.text, let value = Int(valueText) {
               try! bitcoinKit?.send(to: toAddress, value: value, feeRate: 10, sortType: .bip69)
           } else {
               print("Invalid input data")
           }
    }
    
    
    func setupBitcoinKit() {
        
        let seed = Mnemonic.seed(mnemonic: words, passphrase: passphrase)!
        
         bitcoinKit = try? BitcoinKit.Kit(
            seed: seed,
            purpose: Purpose.bip86,
            walletId: walletId,
            syncMode: BitcoinCore.SyncMode.fromDate(date: .init(1694644847)),
            networkType: BitcoinKit.Kit.NetworkType.testNet,
            confirmationsThreshold: 6,
            logger: logger
        )
                
        bitcoinKit?.start()
       
        bitcoinKit?.delegate = self
        print(bitcoinKit?.balance)
        
        replenishmentAddress.text = "Adress:\(bitcoinKit?.receiveAddress())"

        while(true) {
            sleep(10)
            print(bitcoinKit?.balance)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == sendField {
                let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
                let inputCharacterSet = CharacterSet(charactersIn: string)
                return allowedCharacterSet.isSuperset(of: inputCharacterSet)
            } else if textField == addressField {
                let maxLength = 62
                let currentText = textField.text ?? ""
                let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
                textField.backgroundColor = newText.count > maxLength ? .red : .white
                return newText.count <= maxLength
            }
            return true
        }
    
}

extension ViewController: BitcoinCoreDelegate {
    
    func transactionsUpdated(inserted: [TransactionInfo], updated: [TransactionInfo]) {
        print(inserted)
        print(updated)
    }
    
    func transactionsDeleted(hashes: [String]) {
        print(hashes)
    }
    
    func balanceUpdated(balance: BalanceInfo) {
        print(balance)
    }
    
    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
        print(lastBlockInfo)
    }
    
    func kitStateUpdated(state: BitcoinCore.KitState) {
        print(state)
    }
    
}



//let words = ["annual",
//             "sword",
//             "uncle",
//             "unknown",
//             "remove",
//             "decline",
//             "plate",
//             "dust",
//             "choose",
//             "major",
//             "soul",
//             "clever"]
