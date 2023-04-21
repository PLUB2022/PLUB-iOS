//
//  WaitingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/02.
//

import UIKit

protocol MyPageCellDelegate: AnyObject {
  func removeCell(plubbingID: Int)
}

final class WaitingViewController: BaseViewController {
  
  let viewModel: WaitingViewModel
  weak var delegate: MyPageCellDelegate?
  
  init(viewModel: WaitingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var recruitingHeaderView = RecruitingHeaderView()
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.tableHeaderView = recruitingHeaderView
    $0.tableHeaderView?.frame.size.height = 190
    $0.register(RecruitingTableViewCell.self, forCellReuseIdentifier: RecruitingTableViewCell.identifier)
    $0.register(RecruitingSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: RecruitingSectionHeaderView.identifier)
    $0.register(RecruitingSectionFooterView.self, forHeaderFooterViewReuseIdentifier: RecruitingSectionFooterView.identifier)
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
  
  override func setupStyles() {
    setupNavigationBar()
  }
  
  override func bind() {
    viewModel.meetingInfo
      .drive(with: self) { owner, myInfo in
        owner.recruitingHeaderView.setupData(with: myInfo, type: .waiting)
      }
      .disposed(by: disposeBag)
    
    viewModel.reloadData
      .drive(with: self) { owner, _ in
        if owner.viewModel.applications.isEmpty {
          owner.tableView.tableFooterView = RecruitingFooterView()
          owner.tableView.tableFooterView?.frame.size.height = 74
        }
        owner.tableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    viewModel.reloadSection
      .drive(with: self) { owner, index in
        owner.tableView.reloadSections([index], with: .automatic)
      }
      .disposed(by: disposeBag)
    
    viewModel.successCanelApplication
      .drive(with: self) { owner, _ in
        owner.delegate?.removeCell(plubbingID: owner.viewModel.plubbingID)
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
    
    recruitButton
      .rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        let vc = DetailRecruitmentViewController(plubbingID: owner.viewModel.plubbingID)
        owner.navigationController?.pushViewController(vc, animated: true)
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

extension WaitingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let isFolded = viewModel.applications[section].isFolded
    return isFolded ? (16 + 40 + 8) : (16 + 40 + 8 + 8)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecruitingSectionHeaderView.identifier) as? RecruitingSectionHeaderView else {
        return UIView()
    }
    
    let model = viewModel.applications[section]
    headerView.setupData(with: model, sectionIndex: section)
    headerView.delegate = self
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    let isFolded = viewModel.applications[section].isFolded
    return isFolded ? 18 : (14 + 46)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let isFolded = viewModel.applications[section].isFolded
    if isFolded {
      guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyPageSectionFooterView.identifier) as? MyPageSectionFooterView else {
          return UIView()
      }
      return footerView
    } else {
      guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecruitingSectionFooterView.identifier) as? RecruitingSectionFooterView else {
          return UIView()
      }
      let questionCount = viewModel.applications[section].data.answers.count
      footerView.delegate = self
      footerView.setupData(sectionIndex: section, type: .waiting(questionCount: questionCount))
      return footerView
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
}

// MARK: - UITableViewDataSource

extension WaitingViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.applications.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: RecruitingTableViewCell.identifier,
      for: indexPath
    ) as? RecruitingTableViewCell else { return UITableViewCell() }
    
    let model = viewModel.applications[indexPath.section]
    let answer = model.data.answers[indexPath.row]
    cell.setupData(with: answer)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let model = viewModel.applications[section]
    return model.isFolded ? 0 : model.data.answers.count
  }
}

extension WaitingViewController: RecruitingSectionHeaderViewDelegate {
  func foldHeaderView(sectionIndex: Int) {
    viewModel.sectionTapped.onNext(sectionIndex)
  }
}

extension WaitingViewController: RecruitingSectionFooterViewDelegate {
  func firstButtonTapped(sectionIndex: Int) {
    let alert = CustomAlertView(
      AlertModel(
        title: "이 모임에 참여하고 싶지\n않으신가요?",
        message: nil,
        cancelButton: "아니요",
        confirmButton: "네",
        height: 210
      )
    ) { [weak self] in
      guard let self = self else { return }
      self.viewModel.cancelApplication.onNext(sectionIndex)
    }
    alert.show()
  }
  
  func secondButtonTapped(sectionIndex: Int) {
    let answers = viewModel.applications[sectionIndex].data.answers
    let vc = EditApplicationViewController(plubbingID: viewModel.plubbingID, answers: answers)
    vc.delegate = self
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension WaitingViewController: EditApplicationDelegate {
  func editApplication() {
    viewModel.fetchApplicants()
  }
}
