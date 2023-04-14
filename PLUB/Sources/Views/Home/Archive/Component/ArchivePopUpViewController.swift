//
//  ArchivePopUpViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/14.
//

import UIKit

final class ArchivePopUpViewController: BaseViewController {
  
  // MARK: - UI Components
  
  // MARK: - Initializations
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
    // popup motion 적용
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configurations
  
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
