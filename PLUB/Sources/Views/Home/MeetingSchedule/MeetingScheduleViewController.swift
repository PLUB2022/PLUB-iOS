//
//  MeetingScheduleViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/20.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxDataSources

final class MeetingScheduleViewController: BaseViewController {
  private let viewModel = MeetingScheduleViewModel()
  
  private let scheduleTopView = ScheduleTopView()
  
  private let tableView = UITableView().then {
    $0.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.sectionHeaderTopPadding = 0
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [scheduleTopView, tableView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    scheduleTopView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(scheduleTopView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()

    let datasource = viewModel.dataSource()
    viewModel.datas
      .bind(to: tableView.rx.items(dataSource: datasource))
      .disposed(by: disposeBag)
    
    tableView
      .rx.setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  private func setupNavigationBar() {
    title = "요란한 한줄"
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

extension MeetingScheduleViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    if let header = view as? UITableViewHeaderFooterView {
      header.textLabel?.font = .h5
      header.textLabel?.textColor = .black
      header.contentView.backgroundColor = .background
      header.textLabel?.frame = CGRect(x: 16, y: 4, width: tableView.frame.width, height: 31)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 31
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
}
