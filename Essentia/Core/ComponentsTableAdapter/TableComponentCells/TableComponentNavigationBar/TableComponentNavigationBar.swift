//
//  TableComponentNavigationBar.swift
//  Essentia
//
//  Created by Pavlo Boiko on 16.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

class TableComponentNavigationBar: UITableViewCell, NibLoadable {
    // MARK: - Dependences
    private lazy var imageProvider: AppImageProviderInterface = inject()
    
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var leftAction: (() -> Void)?
    var rightAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyDesign()
    }
    
    private func applyDesign() {
        leftButton.isHidden = leftAction != nil
        rightButton.isHidden = rightAction != nil
        
        leftButton.setImage(imageProvider.backButtonImage, for: .normal)
        leftButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: -5)
        leftButton.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        leftAction?()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        rightAction?()
    }
}