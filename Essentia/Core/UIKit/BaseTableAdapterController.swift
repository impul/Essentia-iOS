//
//  BaseTableAdapterController.swift
//  Essentia
//
//  Created by Pavlo Boiko on 15.08.18.
//  Copyright © 2018 Essentia-One. All rights reserved.
//

import UIKit

class BaseTableAdapterController: BaseViewController {
    // MARK: - Init
    var tableView: UITableView
    lazy var tableAdapter = TableAdapter(tableView: tableView)
    private var scrollObserver: NSKeyValueObservation?
    
    public override init() {
        tableView = UITableView()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
    }
    
    private func prepareTableView() {
        setupTableView()
        observeScrollInsets()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.alwaysBounceVertical = false
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        [NSLayoutConstraint.Attribute.top, .bottom, .leading, .trailing].forEach {
            view.addConstraint(NSLayoutConstraint(item: tableView, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0))
        }
    }
    
    private func observeScrollInsets() {
        view.insertSubview(topView!, at: 0)
        view.insertSubview(bottomView!, at: 0)
        scrollObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (_, change) in
            guard let self = self else { return }
            let oneViewHeight = self.view.frame.height / 2
            guard let yChange = change.newValue?.y else { return }
            let overTopScroll = yChange <= -oneViewHeight
            let overBottomScroll = yChange + self.tableView.frame.height > self.tableView.contentSize.height + oneViewHeight
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.isScrollEnabled = !overTopScroll && !overBottomScroll
            })
        }
    }
    
    func fullRebuildTableView() {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.tableView = UITableView()
        self.tableAdapter = TableAdapter(tableView: self.tableView)
        prepareTableView()
    }
}
