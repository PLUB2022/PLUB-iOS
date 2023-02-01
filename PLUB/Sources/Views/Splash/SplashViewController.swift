//
//  SplashViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/01.
//

import UIKit

import SnapKit
import Then

final class SplashViewController: BaseViewController {
  
  private let viewModel = SplashViewModel()
  
  /// PLUB Image
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(imageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    imageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.directionalHorizontalEdges.equalToSuperview().inset(94)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
}
