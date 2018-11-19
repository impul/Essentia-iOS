//
//  WalletWelcomeViewController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 06.09.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

class WalletWelcomeViewController: BaseTableAdapterController {
    // MARK: - Dependences
    private lazy var colorProvider: AppColorInterface = inject()
    private lazy var imageProvider: AppImageProviderInterface = inject()
    private var currentPosition = 1
    private var leftSwipeRecognizer: UISwipeGestureRecognizer!
    private var rightSwipeRecognizer: UISwipeGestureRecognizer!
    
    override init() {
        super.init()
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwipeGesture(gesture:)))
        leftSwipeRecognizer.direction = .left
        rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwipeGesture(gesture:)))
        rightSwipeRecognizer.direction = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyDesign()
        tableAdapter.hardReload(state)
        addRecognizer()
    }
    
    // MARK: - State
    private var state: [TableComponent] {
        return [
            .calculatbleSpace(background: .clear),
            .centeredImage(image: UIImage(named: "walletOnbording\(currentPosition)") ?? UIImage()),
            .empty(height: 45, background: .clear),
            .titleWithFontAligment(font: AppFont.bold.withSize(32), title: LS("Wallet.Onbording\(currentPosition).Title"), aligment: .center, color: .white),
            .descriptionWithSize(aligment: .center,
                                 fontSize: 15,
                                 title: LS("Wallet.Onbording\(currentPosition).Detail"),
                                 background: .clear,
                                 textColor: .white),
            .empty(height: 30, background: .clear),
            .pageControl(count: 3, selected: currentPosition - 1 ),
            .empty(height: 30, background: .clear),
            .actionCenteredButton(title: LS("Wallet.Welcome.Continue"), action: continueAction, backgrount: .white),
            .empty(height: 16, background: .clear)
        ]
    }

    private func applyDesign() {
        self.tableView.backgroundColor = colorForCurrentSegment()
    }
    
    private func addRecognizer() {
        tableView.addGestureRecognizer(leftSwipeRecognizer)
        tableView.addGestureRecognizer(rightSwipeRecognizer)
    }
    
    @objc func leftSwipeGesture(gesture: UISwipeGestureRecognizer) {
        guard currentPosition != 3 else { return }
        currentPosition++
        self.tableAdapter.performTableUpdate(newState: state, withAnimation: .toRight)
        animateBackground()
    }
    
    @objc func rightSwipeGesture(gesture: UISwipeGestureRecognizer) {
        guard currentPosition != 1 else { return }
        currentPosition--
        self.tableAdapter.performTableUpdate(newState: state, withAnimation: .toLeft)
        animateBackground()

    }
    
    private func animateBackground() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.backgroundColor = self.colorForCurrentSegment()
        })
    }
    
    private func colorForCurrentSegment() -> UIColor {
        switch currentPosition {
        case 1:
            return RGB(56, 191, 76)
        case 2:
            return RGB(14, 64, 199)
        case 3:
            return RGB(67, 192, 251)
        default:
            return .white
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Actions
    private lazy var continueAction: () -> Void = { [weak self] in
        self?.dismiss(animated: true)
    }
}
