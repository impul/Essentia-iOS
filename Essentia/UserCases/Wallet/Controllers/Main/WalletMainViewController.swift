//
//  WalletMainViewController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 06.09.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

fileprivate struct Store {
    var tokens: [GeneratingWalletInfo : [TokenWallet]] = [:]
    var generatedWallets: [GeneratedWallet] = []
    var importedWallets: [ImportedWallet] = []
    var currentSegment: Int = 0
    var balanceChangedPer24Hours: Double = 0
    var tableHeight: CGFloat = 0
    
}

class WalletMainViewController: BaseTableAdapterController {
    // MARK: - Dependences
    private lazy var colorProvider: AppColorInterface = inject()
    private lazy var imageProvider: AppImageProviderInterface = inject()
    private lazy var interator: WalletInteractorInterface = inject()
    private lazy var blockchainInterator: WalletBlockchainWrapperInteractorInterface = inject()
    private lazy var store: Store = Store()
    
    private var cashCoinsState: [TableComponent]?
    private var cashTokensState: [TableComponent]?
    private var cashNonEmptyStaticState: [TableComponent]?
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (inject() as LoaderInterface).show()
        injectRouter()
        injectInteractor()
        injectWalletInteractor()
        (inject() as LoaderInterface).hide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hardReload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.store.tableHeight = tableView.frame.height
    }
    
    private func injectInteractor() {
        let injection: WalletInteractorInterface = WalletInteractor()
        prepareInjection(injection, memoryPolicy: .viewController)
    }
    
    private func injectWalletInteractor() {
        let injection: WalletBlockchainWrapperInteractorInterface = WalletBlockchainWrapperInteractor()
        prepareInjection(injection, memoryPolicy: .viewController)
    }
    
    private func injectRouter() {
        guard let navigation = navigationController else { return }
        let injection: WalletRouterInterface = WalletRouter(navigationController: navigation)
        prepareInjection(injection, memoryPolicy: .viewController)
    }
    
    private func cashState() {
        cashCoinsState = coinsState()
        cashTokensState = tokensState()
        cashNonEmptyStaticState = nonEmptyStaticState()
    }
    
    private func clearCash() {
        cashCoinsState = nil
        cashTokensState = nil
        cashNonEmptyStaticState = nil
    }
    
    private func loadData() {
        self.store.generatedWallets = interator.getGeneratedWallets()
        self.store.importedWallets = interator.getImportedWallets()
        self.store.tokens = interator.getTokensByWalleets()
    }
    
    private func state() -> [TableComponent] {
        if EssentiaStore.currentUser.wallet.isEmpty {
            return emptyState()
        }
        let staticState = cashNonEmptyStaticState ?? nonEmptyStaticState()
        let contentHeight = tableAdapter.helper.allContentHeight(for:staticState)
        let emptySpace = store.tableHeight - contentHeight
        let bottomTableContentHeight = emptySpace > 0 ? emptySpace : 0
        return [
            .tableWithHeight(height: contentHeight, state: staticState),
            .tableWithHeight(height: bottomTableContentHeight, state: assetState())
        ]
    }
    
    private func nonEmptyStaticState() -> [TableComponent] {
        return [
            .empty(height: 24, background: colorProvider.settingsCellsBackround),
            .rightNavigationButton(title: LS("Wallet.Title"),
                                   image: imageProvider.bluePlus,
                                   action: addWalletAction),
            .empty(height: 20, background: colorProvider.settingsCellsBackround),
            .titleWithFont(font: AppFont.regular.withSize(20),
                           title: LS("Wallet.Main.Balance.Title"),
                           background: colorProvider.settingsCellsBackround),
            .titleWithFont(font: AppFont.bold.withSize(32),
                           title: formattedBalance(interator.getBalanceInCurrentCurrency()),
                           background: colorProvider.settingsCellsBackround),
            .balanceChanging(status: .idle,
                             balanceChanged: formattedChangePer24Hours(store.balanceChangedPer24Hours) ,
                             perTime: "(24h)",
                             action: updateBalanceChanginPerDay),
            .empty(height: 24, background: colorProvider.settingsCellsBackround),
            .customSegmentControlCell(titles: [LS("Wallet.Main.Segment.First"),
                                               LS("Wallet.Main.Segment.Segment")],
                                      selected: store.currentSegment,
                                      action: segmentControlAction)
        ]
    }
    
    private func assetState() -> [TableComponent] {
        switch store.currentSegment {
        case 0:
            return cashCoinsState ?? coinsState()
        case 1:
            return cashTokensState ?? tokensState()
        default: return []
        }
    }
    
    private func emptyState() -> [TableComponent] {
        return [
            .empty(height: 24, background: colorProvider.settingsCellsBackround),
            .rightNavigationButton(title: "", image: imageProvider.bluePlus, action: addWalletAction),
            .title(bold: true, title: LS("Wallet.Title")),
            .empty(height: 52, background: colorProvider.settingsCellsBackround),
            .centeredImage(image: imageProvider.walletPlaceholder),
            .empty(height: 40, background: colorProvider.settingsCellsBackround),
            .descriptionWithSize(aligment: .center,
                                 fontSize: 17,
                                 title: LS("Wallet.Empty.Description"),
                                 background: colorProvider.settingsCellsBackround),
            .empty(height: 10, background: colorProvider.settingsCellsBackround),
            .smallCenteredButton(title: LS("Wallet.Empty.Add"), isEnable: true, action: addWalletAction)
        ]
    }
    
    private func tokensState() -> [TableComponent] {
        var tokenTabState: [TableComponent] = []
        for (key, value) in store.tokens {
            tokenTabState.append(contentsOf: buildSection(title: key.name, wallets: value))
        }
        return tokenTabState
    }
    
    private func coinsState() -> [TableComponent] {
        var coinsTypesState: [TableComponent] = []
        coinsTypesState.append(contentsOf: buildSection(title: LS("Wallet.Main.Coins.Essntia"),
                                                        wallets: store.generatedWallets))
        coinsTypesState.append(contentsOf: buildSection(title: LS("Wallet.Main.Coins.Imported"),
                                                        wallets: store.importedWallets))
        return coinsTypesState
    }
    
    func buildSection(title: String, wallets: [ViewWalletInterface]) -> [TableComponent] {
        guard !wallets.isEmpty else { return [] }
        var sectionState: [TableComponent] = []
        sectionState.append(.empty(height: 10, background: colorProvider.settingsBackgroud))
        sectionState.append(.descriptionWithSize(aligment: .left,
                                                 fontSize: 14,
                                                 title: title,
                                                 background: colorProvider.settingsBackgroud))
        sectionState.append(.empty(height: 10, background: colorProvider.settingsBackgroud))
        sectionState.append(contentsOf: buildStateForWallets(wallets))
        return sectionState
    }
    
    func buildStateForWallets(_ wallets: [ViewWalletInterface]) -> [TableComponent] {
        var assetState: [TableComponent] = []
        wallets.forEach { (wallet) in
            assetState.append(
                .assetBalance(imageUrl: wallet.iconUrl,
                              title: wallet.name,
                              value: wallet.formattedBalanceInCurrentCurrency,
                              currencyValue: wallet.formattedBalance,
                              action: { self.showWalletDetail(for: wallet) }
                )
            )
            assetState.append(.separator(inset: .zero))
        }
        return assetState
    }
    
    // MARK: - Actions
    private lazy var segmentControlAction: (Int) -> Void = {
        (inject() as LoaderInterface).show()
        self.store.currentSegment = $0
        DispatchQueue.global().async {
            self.loadBalances()
        }
        self.tableAdapter.simpleReload(self.state())
        (inject() as LoaderInterface).hide()
    }
    
    private lazy var addWalletAction: () -> Void = {
        (inject() as WalletRouterInterface).show(.newAssets)
    }
    
    private lazy var updateBalanceChanginPerDay: () -> Void = {
        self.hardReload()
    }
    
    private func showWalletDetail(for wallet: ViewWalletInterface) {
        guard let walletInfo = interator.transformViewWallet(from: wallet) else { return }
        (inject() as WalletRouterInterface).show(.walletDetail(walletInfo))
    }
    
    // MARK: - Private
    
    private func hardReload() {
        reloaddAllComponents()
        (inject() as CurrencyRankDaemonInterface).update { [weak self] in
            self?.reloaddAllComponents()
        }
    }
    
    private func reloaddAllComponents() {
        (inject() as LoaderInterface).show()
            self.clearCash()
            self.loadData()
            self.cashState()
            self.loadBalances()
            self.loadBalanceChangesPer24H()
            self.tableAdapter.simpleReload(self.state())
        (inject() as LoaderInterface).hide()
    }
    
    private func loadBalanceChangesPer24H() {
        interator.getBalanceChangePer24Hours { (changes) in
            self.store.balanceChangedPer24Hours = changes
            self.cashNonEmptyStaticState = self.nonEmptyStaticState()
            self.tableAdapter.simpleReload(self.state())
        }
    }
    
    private func loadBalances() {
        switch store.currentSegment {
        case 0:
            self.loadCoinBalances()
        case 1:
            self.loadTokenBalances()
        default: return
        }
    }
    
    private func loadCoinBalances() {
        self.store.generatedWallets.enumerated().forEach { (arg) in
            blockchainInterator.getCoinBalance(for: arg.element.coin, address: arg.element.address, balance: { (balance) in
                self.store.generatedWallets[arg.offset].lastBalance = balance
                self.tableAdapter.simpleReload(self.state())
            })
        }
        self.store.importedWallets.enumerated().forEach { (arg) in
            blockchainInterator.getCoinBalance(for: arg.element.coin, address: arg.element.address, balance: { (balance) in
                self.store.importedWallets[arg.offset].lastBalance = balance
                EssentiaStore.currentUser.wallet.importedWallets[arg.offset].lastBalance = balance
                self.tableAdapter.simpleReload(self.state())
            })
        }
    }
    
    private func loadTokenBalances() {
        self.store.tokens.forEach { (tokenWallet) in
            tokenWallet.value.enumerated().forEach({ indexedToken in
                blockchainInterator.getTokenBalance(for: indexedToken.element.token, address: indexedToken.element.address, balance: { (balance) in
                    self.store.tokens[tokenWallet.key]?[indexedToken.offset].lastBalance = balance
                    self.tableAdapter.simpleReload(self.state())
                })
            })
        }
    }
    
    private func formattedBalance(_ balance: Double) -> String {
        let formatter = BalanceFormatter(currency: EssentiaStore.currentUser.profile.currency)
        return formatter.formattedAmmount(amount: balance)
    }
    
    private func formattedChangePer24Hours(_ procents: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        formatter.allowsFloats = true
        return formatter.string(from: NSNumber(value: procents)) ?? "0.00%"
    }
}
