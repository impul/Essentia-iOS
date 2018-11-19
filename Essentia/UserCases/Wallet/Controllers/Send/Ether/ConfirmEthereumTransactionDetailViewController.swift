//
//  ConfirmEthereumTransactionDetailViewController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 11/13/18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import Foundation

class ConfirmEthereumTxDetailViewController: BaseTableAdapterController {
    // MARK: - Dependences
    private lazy var colorProvider: AppColorInterface = inject()
    private lazy var imageProvider: AppImageProviderInterface = inject()
    private lazy var interactor: WalletBlockchainWrapperInteractorInterface = inject()
    
    private var wallet: ViewWalletInterface
    private var tx: EtherTxInfo
    
    init(_ wallet: ViewWalletInterface, tx: EtherTxInfo) {
        self.wallet = wallet
        self.tx = tx
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableAdapter.hardReload(state)
        view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
    }
    
    private var state: [TableComponent] {
        return [.blure(state:
            [.centeredComponentTopInstet,
             .container(state: containerState)]
            )]
    }
    
    private var containerState: [TableComponent] {
        return [
            .empty(height: 10, background: .clear),
            .titleWithFontAligment(font: AppFont.bold.withSize(17), title: LS("Wallet.Send.Confirm.Title"), aligment: .center, color: colorProvider.appTitleColor),
            .descriptionWithSize(aligment: .left, fontSize: 14, title: LS("Wallet.Send.Confirm.ToAddress"), background: .clear, textColor: colorProvider.appDefaultTextColor),
            .descriptionWithSize(aligment: .left, fontSize: 13, title: wallet.address, background: .clear, textColor: colorProvider.titleColor),
            .empty(height: 5, background: .clear),
            .descriptionWithSize(aligment: .left, fontSize: 14, title: LS("Wallet.Send.Confirm.Amount"), background: .clear, textColor: colorProvider.appDefaultTextColor),
            .descriptionWithSize(aligment: .left, fontSize: 13, title: formattedTransactionAmmount(), background: .clear, textColor: colorProvider.titleColor),
            .empty(height: 5, background: .clear),
            .descriptionWithSize(aligment: .left, fontSize: 14, title: LS("Wallet.Send.Confirm.Fee"), background: .clear, textColor: colorProvider.appDefaultTextColor),
            .descriptionWithSize(aligment: .left, fontSize: 13, title: formattedFee(), background: .clear, textColor: colorProvider.titleColor),
            .empty(height: 5, background: .clear),
            .descriptionWithSize(aligment: .left, fontSize: 14, title: LS("Wallet.Send.Confirm.Time"), background: .clear, textColor: colorProvider.appDefaultTextColor),
            .descriptionWithSize(aligment: .left, fontSize: 13, title: " ~ 35 min", background: .clear, textColor: colorProvider.titleColor),
            .empty(height: 10, background: .clear),
            .separator(inset: .zero),
            .twoButtons(lTitle: LS("Wallet.Send.Confirm.Cancel"),
                        rTitle: LS("Wallet.Send.Confirm.Send"),
                        lColor: colorProvider.appDefaultTextColor,
                        rColor: colorProvider.centeredButtonBackgroudColor,
                        lAction: cancelAction,
                        rAction: confirmAction),
            .empty(height: 10, background: .clear)
        ]
    }
    
    private func formattedTransactionAmmount() -> String {
        let cryptoFormatter = BalanceFormatter(asset: wallet.asset)
        let inCrypto = cryptoFormatter.formattedAmmountWithCurrency(ammount: tx.ammount.inCrypto)
        let current = EssentiaStore.shared.currentUser.profile.currency
        let currencyFormatter = BalanceFormatter(currency: current)
        let inCurrency = currencyFormatter.formattedAmmount(ammount: tx.ammount.inCrypto)
        return "\(inCrypto) (\(inCurrency) \(current.symbol))"
    }
    
    private func formattedFee() -> String {
        let ammountFormatter = BalanceFormatter(asset: wallet.asset)
        return ammountFormatter.formattedAmmountWithCurrency(amount: tx.fee)
    }
    
    // MARK: - Actions
    private lazy var  cancelAction: () -> Void = { [weak self] in
        self?.dismiss(animated: true)
    }
    
    private lazy var confirmAction: () -> Void = { [weak self] in
        guard let `self` = self else { return }
        (inject() as LoaderInterface).show()
        self.interactor.sendEthTransaction(wallet: self.wallet,
                                      transacionDetial: self.tx) {
                                        (inject() as LoaderInterface).hide()
                                        switch $0 {
                                        case .success(let object):
                                            (inject() as LoggerServiceInterface).log(object)
                                            self.dismiss(animated: true)
                                            (inject() as WalletRouterInterface).show(.doneTx)
                                        case .failure(let error):
                                            (inject() as LoaderInterface).showError(message: error.localizedDescription)
                                        }
        }
    }
}
