//
//  MyPageViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

enum MyPageTableViewCellType: Int, CaseIterable {
  case foldCell = 0 // 접고 펴기 셀
  case contentCell // 상세 내용 셀
}

enum MyPageTableViewFoldType: CaseIterable {
  case fold // 접기
  case unfold // 펴기
}

final class MyPageViewController: BaseViewController {
  private let viewModel = MyPageViewModel()
  private let profileView = MyProfileView()
  
  var isFolded: Bool = true {
    didSet {
      tableView.reloadSections([0], with: .automatic)
    }
  }
  
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
  }
}

// MARK: - UITableViewDelegate

extension MyPageViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return isFolded ? (16 + 24 + 12) : (16 + 24 + 16 + 12)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyPageSectionHeaderView.identifier) as? MyPageSectionHeaderView else {
        return UIView()
    }
    headerView.delegate = self
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MyPageTableViewCell.identifier,
      for: indexPath
    ) as? MyPageTableViewCell else { return UITableViewCell() }
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isFolded ? 0 : 5
  }
}

extension MyPageViewController: MyPageSectionHeaderViewDelegate {
  func foldHeaderView() {
    isFolded.toggle()
  }
}
