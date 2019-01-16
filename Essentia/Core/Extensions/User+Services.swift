//
//  User+Services.swift
//  Essentia
//
//  Created by Pavlo Boiko on 1/10/19.
//  Copyright © 2019 Essentia-One. All rights reserved.
//

import Foundation
import EssModel
import EssCore
import EssResources

extension User {
    convenience init(mnemonic: String) {
        let index = (inject() as UserStorageServiceInterface).freeIndex
        let name = LS("Settings.CurrentAccountTitle.Default") + " (\(index))"
        self.init(mnemonic: mnemonic, index: index, name: name)
    }
    
    convenience init(seed: String) {
        let index = (inject() as UserStorageServiceInterface).freeIndex
        let name = LS("Settings.CurrentAccountTitle.Default") + " (\(index))"
        let icon = (inject() as AppImageProviderInterface).testAvatar
        self.init(seed: seed, index: index, image: icon, name: name)
        
    }
}
