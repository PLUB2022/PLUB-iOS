//
//  ProfileViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/03.
//

import UIKit

import SnapKit
import Then

final class ProfileViewController: BaseViewController {

  
  override func setupLayouts() {
    super.setupLayouts()
  }
  
  override func setupConstraints() {
    super.setupConstraints()
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ProfileViewControllerPreview: PreviewProvider {
  static var previews: some View {
    ProfileViewController().toPreview()
  }
}
#endif

