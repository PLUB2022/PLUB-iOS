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
    let imageURL = "https://img.insight.co.kr/static/2019/04/19/700/2j6xsl93c2fc7c5td0bm.jpg"
    let imageList = [String](repeating: imageURL, count: 10)
    let model = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .middle,
      isPasted: false
    )
    var modelList = [ScheduleTableViewCellModel](repeating: model, count: 10)
    
    
    modelList[0] = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .first,
      isPasted: false
    )
    modelList[modelList.count - 1] = ScheduleTableViewCellModel(
      day: "9월 15일",
      time: "오후 5:30 - 오후 8:00",
      name: "프로젝트 기획",
      location: "투썸 플레이스 강남역점",
      participants: imageList,
      indexType: .last,
      isPasted: true
    )
    
    let data = Observable<[ScheduleTableViewCellModel]>.just(modelList)
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
