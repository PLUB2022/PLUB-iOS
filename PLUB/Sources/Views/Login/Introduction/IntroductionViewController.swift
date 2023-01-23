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
    title: "소개",
    placeHolder: "소개하는 내용을 입력해주세요",
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
  
  // MARK: - First Responder
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    inputTextView.resignFirstResponder()
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
