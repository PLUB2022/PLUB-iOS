//
//  MyPageViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

final class MyPageViewController: BaseViewController {
  private let viewModel = MyPageViewModel()
  private let profileView = MyProfileView()
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .background
    $0.delegate = self
    $0.dataSource = self
    $0.register(MyPageTableViewCell.self, forCellReuseIdentifier: MyPageTableViewCell.identifier)
    $0.register(MyPageSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: MyPageSectionHeaderView.identifier)
    $0.register(MyPageSectionFooterView.self, forHeaderFooterViewReuseIdentifier: MyPageSectionFooterView.identifier)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.fetchMyInfoData()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [profileView, tableView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    profileView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(88)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(profileView.snp.bottom)
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  override func bind() {
    super.bind()
    
    viewModel.myInfo
      .drive(with: self) { owner, myInfo in
        owner.profileView.setupMyProfile(with: myInfo)
      }
      .disposed(by: disposeBag)
    
    viewModel.reloadData
      .drive(with: self) { owner, _ in
        owner.tableView.reloadData()
      }
      .disposed(by: disposeBag)
    
    viewModel.reloadSection
      .drive(with: self) { owner, index in
        owner.tableView.reloadSections([index], with: .automatic)
      }
      .disposed(by: disposeBag)
  }
}

extension MyPageViewController {
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = nil
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "setting"),
      style: .plain,
      target: self,
      action: #selector(didTappedSettingButton)
    )
  }
  
  @objc
  private func didTappedSettingButton() {
    let vc = SettingViewController()
    vc.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(vc, animated: true)
  }
}

// MARK: - UITableViewDelegate

extension MyPageViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let isFolded = viewModel.myPlubbing[section].isFolded
    return isFolded ? (16 + 24 + 12) : (16 + 24 + 16 + 12)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyPageSectionHeaderView.identifier) as? MyPageSectionHeaderView else {
        return UIView()
    }
    
    let model = viewModel.myPlubbing[section]
    headerView.setupData(with: model, sectionIndex: section)
    headerView.delegate = self
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    let isFolded = viewModel.myPlubbing[section].isFolded
    return isFolded ? 16 : 20
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyPageSectionFooterView.identifier) as? MyPageSectionFooterView else {
        return UIView()
    }
    return footerView
  }
}

// MARK: - UITableViewDataSource

extension MyPageViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.myPlubbing.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MyPageTableViewCell.identifier,
      for: indexPath
    ) as? MyPageTableViewCell else { return UITableViewCell() }
    
    let section = viewModel.myPlubbing[indexPath.section].section
    let model = section.plubbings[indexPath.row]
    cell.setupData(with: model)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let model = viewModel.myPlubbing[section]
    return model.isFolded ? 0 : model.section.plubbings.count
  }
}

extension MyPageViewController: MyPageSectionHeaderViewDelegate {
  func foldHeaderView(sectionIndex: Int) {
    viewModel.sectionTapped.onNext(sectionIndex)
  }
}
