//
//  BirthViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/22.
//

import UIKit

import SnapKit
import Then

final class BirthViewController: BaseViewController {
  
  // MARK: - Property
  
  // MARK: Sex Distinction
  
  private let sexStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let sexLabel: UILabel = UILabel().then {
    $0.text = "성별"
    $0.font = .subtitle
  }
  
  private let buttonStackView: UIStackView = UIStackView().then {
    $0.spacing = 16
    $0.alignment = .center
    $0.distribution = .fillEqually
  }
  
  private let maleButton: UIButton = UIButton().then {
    $0.setTitle("남성", for: .normal)
    $0.setTitleColor(.deepGray, for: .normal)
    $0.titleLabel?.font = .body1
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.mediumGray.cgColor
    $0.layer.cornerRadius = 8
  }
  
  private let femaleButton: UIButton = UIButton().then {
    $0.setTitle("여성", for: .normal)
    $0.setTitleColor(.deepGray, for: .normal)
    $0.titleLabel?.font = .body1
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.mediumGray.cgColor
    $0.layer.cornerRadius = 8
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct BirthViewControllerPreview: PreviewProvider {
  static var previews: some View {
    BirthViewController().toPreview()
  }
}
#endif

