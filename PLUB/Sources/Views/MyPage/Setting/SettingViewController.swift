//
//  SettingViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/19.
//

import UIKit

import RxSwift
import RxCocoa

enum SettingType: String, CaseIterable {
  case use = "PLUB 이용"
  case account = "계정"
  case version = "버전"
}

enum SettingUseType: String, CaseIterable {
  case notice = "공지사항"
  case email = "이메일로 문의하기"
  case qna = "Q&A"
  case alarm = "알림 설정"
}

enum SettingAccountType: String, CaseIterable {
  case logout = "로그아웃"
  case inactive = "비활성화"
  case withdraw = "탈퇴"
}

enum SettingVersionType: String, CaseIterable {
  case termsOfService = "서비스 이용 약관"
  case privacyPolicy = "개인정보 처리 방침"
}

final class SettingViewController: BaseViewController {
  private let viewModel: SettingViewModelType
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
    $0.showsVerticalScrollIndicator = false
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 15, left: 0, bottom: 15, right: 0)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "설정"
    $0.font = .h2
  }
  
  init(viewModel: SettingViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [scrollView].forEach {
      view.addSubview($0)
    }
    scrollView.addSubview(contentStackView)
    
    contentStackView.addArrangedSubview(titleLabel)
    
    SettingType.allCases.forEach {
      let subStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .white
      }
      contentStackView.addArrangedSubview(subStackView)
      
      let subView = SettingSubview($0)
      subStackView.addArrangedSubview(subView)
      subView.snp.makeConstraints {
        $0.height.equalTo(50)
      }
      
      addSubViews(stackView: subStackView, type: $0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentStackView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(33)
    }
    
    contentStackView.setCustomSpacing(32, after: titleLabel)
  }
  
  override func bind() {
    super.bind()
    viewModel.successLogout
      .drive(with: self) { owner, _ in
        owner.moveToLoginViewController()
      }
      .disposed(by: disposeBag)
  }
  
  private func addSubViews(stackView: UIStackView, type: SettingType) {
    switch type {
    case .use:
      SettingUseType.allCases.enumerated().forEach { index, useType in
        let isLast = index == SettingUseType.allCases.count - 1
        
        let detailSubview = SettingDetailSubView(useType.rawValue, isLast: isLast)
        stackView.addArrangedSubview(detailSubview)
        detailSubview.snp.makeConstraints {
          $0.height.equalTo(52)
        }
      }
    case .account:
      addAccountViews(stackView: stackView)
    case .version:
      addVersionViews(stackView: stackView)
    }
  }
}

extension SettingViewController {
  private func addAccountViews(stackView: UIStackView) {
    SettingAccountType.allCases.enumerated().forEach { index, accountType in
      let isLast = index == SettingAccountType.allCases.count - 1
      
      let detailSubview = SettingDetailSubView(accountType.rawValue, isLast: isLast)
      stackView.addArrangedSubview(detailSubview)
      detailSubview.snp.makeConstraints {
        $0.height.equalTo(52)
      }
      
      detailSubview.button
        .rx.tap
        .asDriver()
        .drive(with: self) { owner, _ in
          switch accountType {
          case .logout:
            owner.logout()
          case .inactive:
            break
          case .withdraw:
            break
          }
        }
        .disposed(by: disposeBag)
    }
  }
  
  private func addVersionViews(stackView: UIStackView) {
    SettingVersionType.allCases.enumerated().forEach { index, versionType in
      let isLast = index == SettingVersionType.allCases.count - 1
      
      let detailSubview = SettingDetailSubView(versionType.rawValue, isLast: isLast)
      stackView.addArrangedSubview(detailSubview)
      detailSubview.snp.makeConstraints {
        $0.height.equalTo(52)
      }
      
      detailSubview.button
        .rx.tap
        .asDriver()
        .drive(with: self) { owner, _ in
          let url: URL?
          switch versionType {
          case .termsOfService:
            url = URL(string: "https://www.notion.so/2098cfa15876455085ebcc7de6a2ab27?pvs=4")
          case .privacyPolicy:
            url = URL(string: "https://www.notion.so/803896b9686a4acdad1c56cb18eab17a?pvs=4")
          }
          if let url = url {
              UIApplication.shared.open(url)
          }
        }
        .disposed(by: disposeBag)
    }
  }
  
  private func logout() {
    let alert = CustomAlertView(
      AlertModel(
        title: "지금 로그아웃 할까요?",
        message: nil,
        cancelButton: "취소",
        confirmButton: "네, 할게요",
        height: 150
      )
    ) { [weak self] in
      guard let self else { return }
      self.viewModel.logoutButtonTapped.onNext(())
    }
    alert.show()
  }
  
  private func moveToLoginViewController() {
    UserManager.shared.clearUserInformations()
    UserManager.shared.set(isLaunchedBefore: true)
    
    let navigationController = UINavigationController(rootViewController: SplashViewController())
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = navigationController
  }
}
