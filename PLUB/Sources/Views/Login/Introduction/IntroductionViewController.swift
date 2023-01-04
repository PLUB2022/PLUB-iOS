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
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(stackView)
    
    [introductionLabel].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    stackView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
    }
  }
  
  override func bind() {
    super.bind()
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

