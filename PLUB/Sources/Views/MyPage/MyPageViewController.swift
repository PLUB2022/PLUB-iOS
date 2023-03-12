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
  private let tableView = UITableView()
  
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

