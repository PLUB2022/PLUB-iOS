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

