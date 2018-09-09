//
//  SettingsViewController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 13.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static var separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
}

class SettingsViewController: BaseTableAdapterController {
    // MARK: - Dependences
    private lazy var colorProvider: AppColorInterface = inject()
    private lazy var imageProvider: AppImageProviderInterface = inject()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        injectRouter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyDesign()
        updateState()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func updateState() {
        tableAdapter.reload(state)
    }
    
    private func injectRouter() {
        guard let navigation = navigationController else { return }
        let injection: SettingsRouterInterface = SettingsRouter(navigationController: navigation)
        prepareInjection(injection, memoryPolicy: .viewController)
    }
    
    private func applyDesign() {
        tableView.backgroundColor = colorProvider.settingsCellsBackround
    }
    
    private var state: [TableComponent] {
        let profile = EssentiaStore.currentUser.profile
        let rawState: [TableComponent?] =
            [.empty(height: 45, background: colorProvider.settingsCellsBackround),
             .title(bold: true, title: LS("Settings.Title")),
             (EssentiaStore.currentUser.backup.securityLevel < 50) ?
                .accountStrengthAction(action: accountStrenghtAction) :
                .empty(height: 16.0, background: colorProvider.settingsBackgroud),
             .currentAccount(icon: profile.icon,
                             title: LS("Settings.CurrentAccountTitle"),
                             name: EssentiaStore.currentUser.dislayName,
                             action: editCurrentAccountAction),
             .empty(height: 16.0, background: colorProvider.settingsBackgroud),
             .menuTitleDetail(icon: imageProvider.languageIcon,
                              title: LS("Settings.Language"),
                              detail: profile.language.titleString,
                              action: languageAction),
             .separator(inset: Constants.separatorInset),
             .menuTitleDetail(icon: imageProvider.currencyIcon,
                              title: LS("Settings.Currency"),
                              detail: profile.currency.titleString,
                              action: currencyAction),
             .separator(inset: Constants.separatorInset),
             .menuTitleDetail(icon: imageProvider.securityIcon,
                              title: LS("Settings.Security"),
                              detail: "",
                              action: securityAction),
             .separator(inset: Constants.separatorInset),
             .empty(height: 16, background: colorProvider.settingsBackgroud),
             .menuTitleDetail(icon: imageProvider.feedbackIcon,
                              title: LS("Settings.Feedback"),
                              detail: "",
                              action: languageAction),
             .separator(inset: Constants.separatorInset),
             .empty(height: 16, background: colorProvider.settingsBackgroud),
             .menuButton(title: LS("Settings.Switch"),
                         color: colorProvider.settingsMenuSwitchAccount,
                         action: switchAccountAction),
             .empty(height: 1, background: colorProvider.settingsBackgroud),
             .menuButton(title: LS("Settings.LogOut"),
                         color: colorProvider.settingsMenuLogOut,
                         action: logOutAction),
             .empty(height: 95, background: colorProvider.settingsBackgroud)]
        return rawState.compactMap { return $0 }
    }
    
    // MARK: - Actions
    
    private lazy var currencyAction: () -> Void = {
        (inject() as SettingsRouterInterface).show(.currency)
    }
    
    private lazy var switchAccountAction: () -> Void = {
        (inject() as UserStorageServiceInterface).store(user: EssentiaStore.currentUser)
        (inject() as SettingsRouterInterface).show(.switchAccount(callBack: { [weak self] in
            self?.updateState()
        }))
        self.viewDidDisappear(true)
    }
    private lazy var logOutAction: () -> Void = {
        guard EssentiaStore.currentUser.backup.currentlyBackedUp == [] else {
            self.logOutUser()
            return
        }
        let alert = ConfirmLogOutViewController(leftAction: {
            (inject() as SettingsRouterInterface).show(.accountStrength)
        }, rightAction: { [weak self] in
            self?.logOutUser()
        })
        self.present(alert, animated: true)
    }
    
    func logOutUser() {
        (inject() as UserStorageServiceInterface).remove(user: EssentiaStore.currentUser)
        EssentiaStore.currentUser = User.notSigned
        (inject() as SettingsRouterInterface).logOut()
    }
    
    private lazy var darkThemeAction: (Bool) -> Void = { isOn in
        
    }
    
    private lazy var securityAction: () -> Void = {
        (inject() as SettingsRouterInterface).show(.security)
    }
    
    private lazy var languageAction: () -> Void = {
        (inject() as SettingsRouterInterface).show(.language)
    }
    
    private lazy var accountStrenghtAction: () -> Void = {
        (inject() as SettingsRouterInterface).show(.accountStrength)
    }
    
    private lazy var editCurrentAccountAction: () -> Void = {
        (inject() as SettingsRouterInterface).show(.accountName)
    }
}
