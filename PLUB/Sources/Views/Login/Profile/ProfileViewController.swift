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
  
  private let profileLabel: UILabel = UILabel().then {
    $0.text = "프로필 사진"
    $0.font = .subtitle
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(profileLabel)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    profileLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
    }
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

