//
//  ProfileViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/03.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class ProfileViewController: BaseViewController {
  
  // MARK: - Property
  
  private let viewModel = ProfileViewModel()
  
  private let wholeStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  // MARK: Profile Part
  
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
    $0.setImage(UIImage(named: "userDefaultImage"), for: .normal)
  }
  
  private let pencilImageView = UIImageView(image: UIImage(named: "pencilCircle")).then {
    $0.layer.borderColor = UIColor.background.cgColor
    $0.layer.borderWidth = 2
    $0.layer.cornerRadius = 16
    $0.contentMode = .scaleAspectFit
  }
  
  // MARK: Nickname Part
  
  private let nicknameStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let nicknameLabel: UILabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = .subtitle
  }
  
  private lazy var nicknameTextField: PaddingTextField = PaddingTextField().then { textField in
    textField.layer.borderWidth = 1
    textField.layer.cornerRadius = 8
    
    textField.leftView = UIView()
    textField.rightView = UIButton().then {
      $0.setImage(UIImage(named: "xMark")?.withRenderingMode(.alwaysTemplate), for: .normal)
      $0.addAction(UIAction { _ in textField.text = "" }, for: .touchUpInside)
    }
    textField.leftViewMode = .always
    textField.rightViewMode = .always
    
    textField.leftViewPadding = 8
    textField.rightViewPadding = 8
    
    textField.textColor = .black
    textField.font = .body1
    
    textField.delegate = self
  }
  
  // MARK: Alert in Nickname
  
  private let alertStackView: UIStackView = UIStackView().then {
    $0.spacing = 4
    $0.distribution = .fillProportionally
    $0.alignment = .center
  }
  
  private let alertImageView: UIImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }
  
  private let alertLabel: UILabel = UILabel().then {
    $0.font = .caption
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(wholeStackView)
    
    [profileStackView, nicknameStackView].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    [profileLabel, uploadImageButton].forEach {
      profileStackView.addArrangedSubview($0)
    }
    
    uploadImageButton.addSubview(pencilImageView)
    
    [nicknameLabel, nicknameTextField, alertStackView].forEach {
      nicknameStackView.addArrangedSubview($0)
    }
    
    [alertImageView, alertLabel].forEach {
      alertStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    wholeStackView.snp.makeConstraints {
      $0.top.horizontalEdges.equalToSuperview()
    }
    
    uploadImageButton.snp.makeConstraints {
      $0.size.equalTo(120)
    }
    
    pencilImageView.snp.makeConstraints {
      $0.size.equalTo(32)
      $0.trailing.bottom.equalToSuperview()
    }
    
    profileLabel.snp.makeConstraints {
      $0.leading.equalToSuperview()
    }
    
    nicknameTextField.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    alertImageView.snp.makeConstraints {
      $0.size.equalTo(18)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    configureInitialUI()
  }
  
  override func bind() {
    super.bind()
    
    nicknameTextField.rx.text
      .orEmpty
      .skip(1)
      .distinctUntilChanged()
      .filter { $0 == "" }
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.configureInitialUI()
      })
      .disposed(by: disposeBag)
  }
  
  /// 최초 상태의 UI를 설정합니다. (textField, label, bubble image 등)
  private func configureInitialUI() {
    
    // placeholder 폰트 설정
    nicknameTextField.attributedPlaceholder = NSAttributedString(
      string: Constants.placeholder,
      attributes: [.font: UIFont.body2!]
    )
    
    nicknameTextField.layer.borderColor = UIColor.mediumGray.cgColor
    nicknameTextField.rightView?.tintColor = .mediumGray
    
    alertLabel.text = Constants.initialAlertMessage
    alertLabel.textColor = .mediumGray
    
    alertImageView.image = UIImage(named: "bubbleWarning")
  }
}

extension ProfileViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    textField.textColor = .black
    return range.location < 15
  }
}

extension ProfileViewController {
  
  enum Constants {
    static let placeholder = "한글, 영문, 숫자 포함 8글자로 입력가능해요."
    static let initialAlertMessage = "닉네임 변경은 한번만 가능해요"
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
