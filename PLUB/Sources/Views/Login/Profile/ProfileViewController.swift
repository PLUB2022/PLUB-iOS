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
  
  private let nicknameTextField: IDCheckTextField = IDCheckTextField().then { textField in
    textField.layer.borderWidth = 1
    textField.layer.borderColor = UIColor.mediumGray.cgColor
    textField.layer.cornerRadius = 8
    textField.placeholder = "한글, 영문, 숫자 포함 8글자로 입력가능해요."
  }
  
  private let alertStackView: UIStackView = UIStackView().then {
    $0.spacing = 4
    $0.distribution = .fillProportionally
    $0.alignment = .center
  }
  
  private let alertImageView: UIImageView = UIImageView().then {
    $0.image = UIImage(named: "bubble_warning")
    $0.contentMode = .scaleAspectFit
  }
  
  private let alertLabel: UILabel = UILabel().then {
    $0.text = "닉네임 변경은 한번만 가능해요"
    $0.textColor = .mediumGray
    $0.font = .caption
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(wholeStackView)
    
    [profileStackView, nicknameStackView].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    [profileLabel, uploadImageButton].forEach {
      profileStackView.addArrangedSubview($0)
    }
    
    [nicknameLabel, nicknameTextField, alertStackView].forEach {
      nicknameStackView.addArrangedSubview($0)
    }
    
    [alertImageView, alertLabel].forEach {
      alertStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    wholeStackView.snp.makeConstraints { make in
      make.top.horizontalEdges.equalToSuperview()
    }
    
    uploadImageButton.snp.makeConstraints { make in
      make.size.equalTo(120)
    }
    
    profileLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
    }
    
    nicknameTextField.snp.makeConstraints { make in
      make.height.equalTo(46)
    }
    
    alertImageView.snp.makeConstraints { make in
      make.size.equalTo(18)
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

