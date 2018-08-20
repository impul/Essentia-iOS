//
//  TabBarController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 09.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

fileprivate enum TabBarTab {
    case launchpad
    case wallet
    case notifications
    case settings
    
    private var title: String {
        switch self {
        case .launchpad:
            return LS("TabBar.Launchpad")
        case .wallet:
            return LS("TabBar.Wallet")
        case .notifications:
            return LS("TabBar.Notifications")
        case .settings:
            return LS("TabBar.Settings")
        }
    }
    
    private var icon: UIImage {
        let imageProvider: AppImageProviderInterface = inject()
        switch self {
        case .launchpad:
            return imageProvider.launchpadIcon
        case .wallet:
            return imageProvider.walletIcon
        case .notifications:
            return imageProvider.notificationsIcon
        case .settings:
            return imageProvider.settingsIcon
        }
    }
    
    private var controller: UIViewController {
        switch self {
        case .launchpad:
            return LaunchpadViewController()
        case .wallet:
            return UIViewController()
        case .notifications:
            return UIViewController()
        case .settings:
            return SettingsViewController()
        }
    }
    
    var tabBarItem: UIViewController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: title, image: icon, selectedImage: nil)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
}

class TabBarController: BaseTabBarController, UITabBarControllerDelegate {
    // MARK: - Init
    override init() {
        super.init()
        delegate = self
        let items: [TabBarTab] = [.launchpad, .wallet, .notifications, .settings]
        viewControllers = items.map { return $0.tabBarItem }
        hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}