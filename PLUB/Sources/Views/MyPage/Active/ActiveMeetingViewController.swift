//
//  ActiveMeetingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/27.
//

import UIKit

final class ActiveMeetingViewController: BaseViewController {
  private let viewModel: ActiveMeetingViewModel
  private let recruitingHeaderView = RecruitingHeaderView()
    
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableHeaderView = recruitingHeaderView
    $0.tableHeaderView?.frame.size.height = 114
    $0.register(MyTodoTableViewCell.self, forCellReuseIdentifier: MyTodoTableViewCell.identifier)
    $0.register(MyTodoSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyTodoSectionHeaderView.identifier)
  }
  
  init(viewModel: ActiveMeetingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    tableView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    viewModel.meetingInfo
      .drive(with: self) { owner, myInfo in
        owner.recruitingHeaderView.setupData(with: myInfo, type: .active)
      }
      .disposed(by: disposeBag)
  }
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

// MARK: - UITableViewDelegate

extension ActiveMeetingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyTodoSectionHeaderView.identifier) as? MyTodoSectionHeaderView else {
        return UIView()
    }

    switch MyActivityType.allCases[section] {
    case .todo: headerView.setupData(type: .todo)
    case .post: headerView.setupData(type: .post)
    }

    return headerView
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .zero
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
}

// MARK: - UITableViewDataSource

extension ActiveMeetingViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MyTodoTableViewCell.identifier,
      for: indexPath
    ) as? MyTodoTableViewCell else { return UITableViewCell() }

    cell.setupData()

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
}
