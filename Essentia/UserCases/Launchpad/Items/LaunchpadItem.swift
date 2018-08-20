//
//  LaunchpadItem.swift
//  Essentia
//
//  Created by Pavlo Boiko on 08.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

protocol LaunchpadItemInterface {
    var title: String { get }
    var subTitle: String { get }
    var icon: UIImage { get }
    func show(from navigationController: UINavigationController)
}

class TestItem: LaunchpadItemInterface {
    var title: String = "dApp Store"
    
    var subTitle: String = "dapp store"
    
    var icon: UIImage = #imageLiteral(resourceName: "dStoreIcon")
    
    func show(from navigationController: UINavigationController) {
        navigationController.tabBarController?.hidesBottomBarWhenPushed = true
        prepareInjection(BackupRouter(navigationController: navigationController, mnemonic: "duty stable equal capable scrap suffer field penalty aspect hazard awake stand dilemma ancient unknown", type: .keystore) as BackupRouterInterface, memoryPolicy: .viewController)
    }
}