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

final class MeetingScheduleViewController: BaseViewController {
  private let viewModel = MeetingScheduleViewModel()
  
  private let scheduleTopView = ScheduleTopView()
  
  private let tableView = UITableView().then {
    $0.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
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
    let data = Observable<[ScheduleTableViewCellModel]>.just([ScheduleTableViewCellModel(day: "f", time: "d", name: "s", location: "ddd", participants: [])])
    data
      .bind(to: tableView.rx.items) { tableView, row, item -> UITableViewCell in
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: "ScheduleTableViewCell",
          for: IndexPath(row: row, section: 0)
        ) as? ScheduleTableViewCell
        else { return UITableViewCell() }
        cell.setupData(
          with: item
        )
        return cell
      }
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
