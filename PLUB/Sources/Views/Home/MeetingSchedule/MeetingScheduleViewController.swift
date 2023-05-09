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
  private let viewModel: MeetingScheduleViewModel
  
  private let scheduleTopView = ScheduleTopView()
  
  private let tableView = UITableView().then {
    $0.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.sectionHeaderTopPadding = 0
  }
  
  init(viewModel: MeetingScheduleViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    tableView.addGestureRecognizer(longPressGesture)
  }
  
  override func bind() {
    super.bind()

    scheduleTopView.addScheduleControl
      .rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        let vc = CreateScheduleViewController(viewModel: CreateScheduleViewModel(plubbingID: owner.viewModel.plubbingID))
        vc.delegate = owner
        owner.navigationController?.pushViewController(vc, animated: true)
      }
      .disposed(by: disposeBag)

    let datasource = viewModel.dataSource()
    viewModel.scheduleList
      .drive(tableView.rx.items(dataSource: datasource))
      .disposed(by: disposeBag)

    tableView.rx.modelSelected(ScheduleTableViewCellModel.self)
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        let vc = ScheduleParticipantViewController(
          plubbingID: owner.viewModel.plubbingID,
          data: data
        )
        vc.delegate = owner
        vc.modalPresentationStyle = .overFullScreen
        owner.present(vc, animated: false)
      })
      .disposed(by: disposeBag)

    tableView
      .rx.setDelegate(self)
      .disposed(by: disposeBag)

    tableView
      .rx.contentOffset
      .compactMap { [tableView] offset in
        return (tableView.contentSize.height, offset.y)
      }
      .bind(to: viewModel.offsetObserver)
      .disposed(by: disposeBag)
  }
  
  private func setupNavigationBar() {
    title = "요란한 한줄"
  }
  
  @objc
  func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    guard gestureRecognizer.state == .began,
          let indexPath = tableView.indexPathForRow(at: gestureRecognizer.location(in: tableView)),
          let calendarID = viewModel.getCellScheduleID(indexPath) else { return }
    let vc = ScheduleBottomSheetViewController(calendarID: calendarID)
    vc.delegate = self
    present(vc, animated: true)
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

extension MeetingScheduleViewController: MeetingScheduleDelegate {
  func refreshScheduleData() {
    viewModel.fetchScheduleList()
  }
}

extension MeetingScheduleViewController: ScheduleBottomSheetDelegate {
  func editSchedule(calendarID: Int) {
    let vc = CreateScheduleViewController(
      viewModel: CreateScheduleViewModel(
        plubbingID: viewModel.plubbingID,
        calendarID: calendarID
      )
    )
    vc.delegate = self
    navigationController?.pushViewController(vc, animated: true)
  }
  
  func deleteSchedule(calendarID: Int) {
    viewModel.deleteSchedule(calendarID: calendarID)
  }
}
