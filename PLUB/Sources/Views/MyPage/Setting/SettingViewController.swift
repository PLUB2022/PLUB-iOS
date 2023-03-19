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
      
      let subView = SettingSubview($0.rawValue)
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
  
  override func setupStyles() {
    super.setupStyles()
    setupNavigationBar()
  }
  
  private func addSubViews(stackView: UIStackView, type: SettingType) {
    switch type {
    case .use:
      SettingUseType.allCases.forEach {
        let detailSubview = SettingDetailSubView($0.rawValue)
        stackView.addArrangedSubview(detailSubview)
        detailSubview.snp.makeConstraints {
          $0.height.equalTo(52)
        }
      }
    case .account:
      SettingAccountType.allCases.forEach {
        let detailSubview = SettingDetailSubView($0.rawValue)
        stackView.addArrangedSubview(detailSubview)
        detailSubview.snp.makeConstraints {
          $0.height.equalTo(52)
        }
      }
    case .version:
      SettingVersionType.allCases.forEach {
        let detailSubview = SettingDetailSubView($0.rawValue)
        stackView.addArrangedSubview(detailSubview)
        detailSubview.snp.makeConstraints {
          $0.height.equalTo(52)
        }
      }
    }
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
