//
//  RecruitingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/15.
//

import Foundation
import UIKit

class RecruitingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
  
  let viewModel: RecruitingViewModel
  
  init(viewModel: RecruitingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  private lazy var recruitingHeaderView = RecruitingHeaderView()
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableHeaderView = recruitingHeaderView
    $0.tableHeaderView?.frame.size.height = 194
    $0.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
    $0.register(MyPageSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyPageSectionHeaderView.identifier)
    $0.register(MyPageSectionFooterView.self, forHeaderFooterViewReuseIdentifier: MyPageSectionFooterView.identifier)
  }
  
  private let recruitButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "모집글 바로가기")
    $0.layer.cornerRadius = 16
    $0.layer.masksToBounds = true
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [tableView, recruitButton].forEach {
      view.addSubview($0)
    }
  }
  override func setupConstraints() {
    tableView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    recruitButton.snp.makeConstraints {
      $0.height.equalTo(32)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(24)
    }
  }
}
