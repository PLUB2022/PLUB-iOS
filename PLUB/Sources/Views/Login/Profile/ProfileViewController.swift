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
  
  private let wholeStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  private let profileStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 16
  }
  
  private let profileLabel: UILabel = UILabel().then {
    $0.text = "프로필 사진"
    $0.font = .subtitle
  }
  
  private let uploadImageButton: UIButton = UIButton().then {
    $0.setImage(UIImage(named: "btn_user_default_image"), for: .normal)
  }
  
  private let nicknameStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let nicknameLabel: UILabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = .subtitle
  }
  
  private let nicknameTextField: UITextField = UITextField().then { textField in
    textField.placeholder = "한글, 영문, 숫자 포함 8글자로 입력가능해요."
  }
  
  private let alertStackView: UIStackView = UIStackView().then {
    $0.spacing = 4
  }
  
  private let alertImageView: UIImageView = UIImageView()
  
  private let alertLabel: UILabel = UILabel().then {
    $0.text = "닉네임 변경은 한번만 가능해요"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [profileStackView].forEach {
      view.addSubview($0)
    }
    [profileLabel, uploadImageButton].forEach {
      profileStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    profileStackView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
    }
    
    uploadImageButton.snp.makeConstraints { make in
      make.size.equalTo(120)
    }
    
    profileLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
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

