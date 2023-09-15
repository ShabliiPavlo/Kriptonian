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
//import Combine
//import RxSwift

class ViewController: UIViewController {
    
    // тут вроде понятно
    let words = ["clerk", "brave", "clever", "mean", "prize", "timber", "stage", "tragic", "between", "text", "clerk", "rival"]
    // я не ставил, у меня пустая
    let passphrase: String = ""
    
    let walletId: String = "MySoUniqueIdForWallet"
    
    let logger: Logger = .init(minLogLevel: .verbose)
    
//    var cancellables: Set<AnyCancellable> = []
//    let disposeBag = DisposeBag() // This must be retained

    override func viewDidLoad() {
        super.viewDidLoad()
                
        
        let seed = Mnemonic.seed(mnemonic: words, passphrase: passphrase)!
        
        guard let bitcoinKit = try? BitcoinKit.Kit(
            //твой сгенерированый сид
            seed: seed,
            // тип кошелька, я не понимаю, но этот вроде работает
            purpose: Purpose.bip86,
            // id для твоего кошелька, на случай если их будет несколько
            walletId: walletId,
            // с какого момента ему синхронизировать даные из пула.
            // вероятно то что было до – можешь не узнать (например транзакции) если синхронизируешься с времени после.
            // У мня тут : (текущееВремя-24часа) в секундах.
            syncMode: BitcoinCore.SyncMode.fromDate(date: .init(1694644847)),
            // мы же в тестовой сети
            networkType: BitcoinKit.Kit.NetworkType.testNet,
            // сколько должно быть подтверждений транзакции, что бы она считалась валидной
            confirmationsThreshold: 1,
            // логгер, красиво сыпет кучей инфы в дебаг, .verbose это очень много инфы))
            logger: logger
        ) else { return }
                
        // start рыботает, stop – не работает
        bitcoinKit.start()
        
        // делегат
        bitcoinKit.delegate = self
        print(bitcoinKit.balance)
        
        // в жизни такое не используй никогда, святой воды отмыться не хватит, но раз в 10 секунд дает возможность зайти в brraekpoint и повыводить что-то через po в дебаг консоли
        while(true) {
            sleep(10)
            print(bitcoinKit.balance)
        }
    }


}

extension ViewController: BitcoinCoreDelegate {
    
    // получаешь информацию по транзакциям относяшимся к твоему кошельку
    // вероятно inserted – только появившеяся
    // updated – когда по ней обновления подтверждений от сети проходят
    func transactionsUpdated(inserted: [TransactionInfo], updated: [TransactionInfo]) {
        print(inserted)
        print(updated)
    }
    
    // не представляю как это, но пусть будут удаленные транзакции XD
    func transactionsDeleted(hashes: [String]) {
        print(hashes)
    }
    
    // из-за транзакций обновлен баланс
    func balanceUpdated(balance: BalanceInfo) {
        print(balance)
    }
    
    // это синхронизации сети, тебе вроде не надо
    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
        print(lastBlockInfo)
    }
    
    // тут на каждый новый блок меняется статус, syncing пока идет синхронизация и толку с кошелька не будет и synced когда оно завершилась и ве ок
    // остальное вроде не важно
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
