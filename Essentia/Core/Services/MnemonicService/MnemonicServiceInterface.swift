//
//  MnemonicServiceInterface.swift
//  Essentia
//
//  Created by Pavlo Boiko on 19.07.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import Foundation

protocol MnemonicServiceInterface {
    func wordList() -> [String]
    func wordList(with language: MnemonicLanguage) -> [String]
    func newMnemonic(with language: MnemonicLanguage) -> String
    func seed(from mnemonic: String) -> String
    func keyStoreFile(seed: String, password: String) throws -> Data
    func seed(from keystoreFile: Data, password: String) -> String?
    func languageForCurrentLocale() -> MnemonicLanguage
}
