//
//  IntroductionViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

import SnapKit
import Then

final class IntroductionViewController: BaseViewController {
  
  // MARK: - Property
  
  private let stackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
  }
  
  private let introductionLabel: UILabel = UILabel().then {
    $0.text = "소개"
    $0.font = .subtitle
  }
  
  private lazy var introductionTextView: UITextView = UITextView().then {
    $0.text = placeHolder
    $0.textColor = .deepGray
    $0.font = .body2
    $0.backgroundColor = .white
    $0.textContainerInset = UIEdgeInsets(top: 14, left: 8, bottom: 14, right: 8)
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(stackView)
    
    [introductionLabel, introductionTextView].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    stackView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
    }
    
    introductionTextView.snp.makeConstraints { make in
      make.height.equalTo(46)
    }
  }
  
  override func bind() {
    super.bind()
  }
}

// MARK: - Constants

extension IntroductionViewController {
  private var placeHolder: String {
    return "소개하는 내용을 입력해주세요"
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct IntroductionViewControllerPreview: PreviewProvider {
  static var previews: some View {
    IntroductionViewController().toPreview()
  }
}
#endif

