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
  
  private let viewModel = IntroductionViewModel()
  
  weak var delegate: SignUpChildViewControllerDelegate?
  
  private let inputTextView = InputTextView(
    title: Constants.title,
    placeHolder: Constants.placeholder,
    options: .textCount,
    totalCharacterLimit: 150
  )
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(inputTextView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    inputTextView.snp.makeConstraints {
      $0.top.horizontalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
    
    // 사용자가 소개글 입력시
    inputTextView.rx.text
      .orEmpty
      .filter { $0 != Constants.placeholder } // placeholder 필터링
      .distinctUntilChanged()
      .skip(1) // 처음 구독시 빈 값이 들어옴
      .bind(to: viewModel.introductionText)
      .disposed(by: disposeBag)
    
    // 버튼 활성화 여부
    viewModel.isButtonEnabled
      .drive(with: self, onNext: { owner, flag in
        // delegate에 전달
        owner.delegate?.checkValidation(index: 3, state: flag)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Constants

extension IntroductionViewController {
  enum Constants {
    
    /// textView 위에 존재할 titleLabel
    static let title = "소개"
    
    /// textView의 placeholder
    static let placeholder = "소개하는 내용을 입력해주세요"
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
