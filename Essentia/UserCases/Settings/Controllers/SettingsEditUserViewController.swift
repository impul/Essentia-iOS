//
//  SettingsEditUserViewController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 30.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import Foundation

class SettingsEditUserViewController: BaseTableAdapterController {
    // MARK: - Dependences
    private lazy var colorProvider: AppColorInterface = inject()
    private lazy var router: SettingsRouterInterface = inject()
    private var enteredName: String = EssentiaStore.currentUser.dislayName
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableAdapter.reload(state)
        applyDesign()
    }
    
    // MARK: - Design
    private func applyDesign() {
        tableView.backgroundColor = colorProvider.settingsBackgroud
    }
    
    private var state: [TableComponent] {
        return [
            .empty(height: 25, background: colorProvider.settingsCellsBackround),
            .navigationBar(left: LS("EditAccount.Back"),
                           right: LS("EditAccount.Done"),
                           title: LS("EditAccount.Title"),
                           lAction: backAction,
                           rAction: doneAction),
            .empty(height: 15, background: colorProvider.settingsBackgroud),
            .textField(placeholder: LS("EditAccount.Placeholder") + EssentiaStore.currentUser.dislayName,
                       text: enteredName,
                       endEditing: nameAction),
            .separator(inset: .zero),
            .description(title: LS("EditAccount.Description"), backgroud: colorProvider.settingsBackgroud)
            ]
    }

    // MARK: - Actions
    
    private lazy var nameAction: (String) -> Void = {
        self.enteredName = $0
    }
    
    private lazy var backAction: () -> Void = {
        self.router.pop()
    }
    
    private lazy var doneAction: () -> Void = {
        guard !self.enteredName.isEmpty else {
            return
        }
        self.view.endEditing(true)
        EssentiaStore.currentUser.name = self.enteredName
        self.router.pop()
    }
    
    private lazy var keyStoreAction: () -> Void = {
        self.router.show(.backupKeystore)
    }
}