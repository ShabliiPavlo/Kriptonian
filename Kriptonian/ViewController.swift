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
    
    @IBOutlet weak var hesh: UILabel!
    var bitcoinKit: BitcoinKit.Kit?
    var transactions: [Transaction] = []
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelDidGetTapped))
        
        replenishmentAddress.isUserInteractionEnabled = true
        replenishmentAddress.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func updateBalance(_ sender: Any) {
        let satoshiBalance = bitcoinKit?.balance.spendable ?? 0
        let bitcoinBalance = Double(satoshiBalance) / 100000000.0
        wallet.text = "Bitcoin: \(bitcoinBalance.formatted())"
    }
    @IBAction func sendButton(_ sender: Any) {
        if let toAddress = addressField.text, let valueText = sendField.text, let value = Double(valueText) {
            let satoshi = Int(value * 100_000_000)
            let result = try? bitcoinKit?.send(to: toAddress, value: satoshi, feeRate: 1, sortType: .bip69)
            print(result as Any)
        } else {
            print("Invalid input data")
        }
        hesh.text = "\(TransactionFilterType.incoming.hashValue)"
    }
    
    @objc
    func labelDidGetTapped(sender: UITapGestureRecognizer) {
        copyAlert()
        guard let label = sender.view as? UILabel else {
            return
        }
        UIPasteboard.general.string = label.text
    }
    
    func copyAlert() {
        if let address = replenishmentAddress?.text?.trimmingCharacters(in: .whitespaces) {
            UIPasteboard.general.setValue(address, forPasteboardType: "public.plain-text")
            
            let alert = UIAlertController(title: "Success", message: "Address copied", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
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
            confirmationsThreshold: 1,
            logger: logger
        )
        
        bitcoinKit?.start()
        
        bitcoinKit?.delegate = self
        print(bitcoinKit?.balance ?? 0)
        bitcoinKit?.transactions(type: TransactionFilterType.incoming)
        print(TransactionFilterType.incoming.hashValue)
       
        replenishmentAddress.text = "Adress:\(bitcoinKit?.receiveAddress() ?? "")"
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == sendField {
            return CharacterSet(charactersIn: string).isSubset(of: CharacterSet(charactersIn: "0123456789."))
        } else if textField == addressField {
            let maxLength = 62
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if newText.count > maxLength {
                textField.backgroundColor = .red
                return false
            } else {
                textField.backgroundColor = .white
                return true
            }
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
        print("\(balance)+++++++++++")
    }
    
    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
        print(lastBlockInfo)
    }
    
    func kitStateUpdated(state: BitcoinCore.KitState) {
        print(state)
    }
    
}
