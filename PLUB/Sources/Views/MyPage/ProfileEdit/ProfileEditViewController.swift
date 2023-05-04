//
//  ProfileEditViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/05.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

protocol ProfileEditDelegate: AnyObject {
  func updateProfile(myInfo: MyInfoResponse)
}

final class ProfileEditViewController: BaseViewController {
  
  weak var delegate: ProfileEditDelegate?
  
  // MARK: - Property
  
  private let viewModel: ProfileEditViewModel
  
  private let wholeStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  // MARK: Profile Part
  
  private let profileStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 16
  }
  
  private let profileLabel = UILabel().then {
    $0.text = "프로필 사진"
    $0.font = .subtitle
  }
  
  private let uploadImageButton = UIButton().then {
    $0.imageView?.contentMode = .scaleAspectFill
    $0.layer.cornerRadius = 60
    $0.clipsToBounds = true
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
  
  private lazy var nicknameTextField = PaddingTextField(left: 8, right: 8).then {
    $0.layer.borderWidth = 1
    $0.layer.cornerRadius = 8
    
    $0.rightView = UIButton().then {
      $0.setImage(UIImage(named: "xMark")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    $0.textColor = .black
    $0.font = .body1
    
    $0.delegate = self
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
  
  // MARK: Introduction
  
  private let introductionTextView = InputTextView(
    title: Constants.introduction,
    placeHolder: Constants.introductionPlaceholder,
    options: [.textCount],
    totalCharacterLimit: 150
  )
  
  // MARK: Save Button
  
  private let saveButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "저장")
  }
  
  // MARK: - Configuration
  
  init(viewModel: ProfileEditViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    setupPreData(myInfoData: viewModel.myInfoData) // 이전 프로필 정보 세팅
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [wholeStackView, pencilImageView, saveButton].forEach {
      view.addSubview($0)
    }
    
    [profileStackView, nicknameStackView, introductionTextView].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    wholeStackView.setCustomSpacing(39, after: nicknameStackView)
    
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
    
    wholeStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
      $0.directionalHorizontalEdges.equalToSuperview().inset(24)
    }
    
    uploadImageButton.snp.makeConstraints {
      $0.size.equalTo(120)
    }
    
    pencilImageView.snp.makeConstraints {
      $0.size.equalTo(32)
      $0.trailing.bottom.equalTo(uploadImageButton)
    }
    
    saveButton.snp.makeConstraints {
      $0.height.equalTo(46)
      $0.directionalHorizontalEdges.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(26)
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
    
    uploadImageButton.rx.tap
      .asDriver()
      .drive(with: self, onNext: { owner, _ in
        let photoVC = PhotoBottomSheetViewController()
        photoVC.modalPresentationStyle = .overFullScreen
        photoVC.delegate = owner
        owner.parent?.present(photoVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    (nicknameTextField.rightView as? UIButton)?.rx.tap
      .asDriver()
      .drive(with: self, onNext: { owner, _ in
        owner.nicknameTextField.text = ""
        owner.configureInitialUI()
      })
      .disposed(by: disposeBag)
    
    nicknameTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .filter { $0 == "" }
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.configureInitialUI()
      })
      .disposed(by: disposeBag)
    
    nicknameTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .filter { $0 != "" }
      .bind(to: viewModel.nicknameText)
      .disposed(by: disposeBag)
    
    introductionTextView.textView.rx.text
      .orEmpty
      .distinctUntilChanged()
      .bind(to: viewModel.introduceText)
      .disposed(by: disposeBag)
    
    viewModel.isAvailableNickname
      .drive(with: self) { owner, flag in
        owner.updateNicknameValidationUI(isValid: flag)
      }
      .disposed(by: disposeBag)
    
    viewModel.alertMessage
      .drive(alertLabel.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.isButtonEnabled
      .drive(saveButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    saveButton
      .rx.tap
      .bind(to: viewModel.updateButtonTapped)
      .disposed(by: disposeBag)
    
    viewModel
      .successUpdateProfile
      .drive(with: self) { owner, myInfo in
        owner.delegate?.updateProfile(myInfo: myInfo)
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  private func configureInitialUI() {
    
    // placeholder 폰트 설정
    nicknameTextField.attributedPlaceholder = NSAttributedString(
      string: Constants.nicknamePlaceholder,
      attributes: [.font: UIFont.body2]
    )
    
    nicknameTextField.layer.borderColor = UIColor.mediumGray.cgColor
    nicknameTextField.rightView?.tintColor = .mediumGray
    
    alertLabel.text = Constants.nicknameAlertMessage
    alertLabel.textColor = .mediumGray
    
    alertImageView.image = UIImage(named: "bubbleWarning")
  }
  
  private func setupPreData(myInfoData: MyInfoResponse) {
    if let profileImage = myInfoData.profileImage,
        let profileImageUrl = URL(string: profileImage) {
      uploadImageButton.kf.setImage(with: profileImageUrl, for: .normal)
    }
    
    nicknameTextField.text = myInfoData.nickname
    introductionTextView.textView.text = myInfoData.introduce
  }
  
  /// 닉네임 검증 여부에 따라 색을 지정해줍니다.
  private func updateNicknameValidationUI(isValid: Bool) {
    if isValid {
      alertLabel.textColor = .main
      nicknameTextField.rightView?.tintColor = .main
      nicknameTextField.layer.borderColor = UIColor.main.cgColor
      alertImageView.image = UIImage(named: "bubbleCheck")
    } else {
      alertLabel.textColor = .error
      alertImageView.tintColor = .error
      nicknameTextField.textColor = .error
      nicknameTextField.rightView?.tintColor = .error
      nicknameTextField.layer.borderColor = UIColor.error.cgColor
      alertImageView.image = UIImage(named: "bubbleWarning")?.withRenderingMode(.alwaysTemplate)
    }
  }
}

extension ProfileEditViewController: PhotoBottomSheetDelegate {
  func selectImage(image: UIImage) {
    uploadImageButton.setImage(image, for: .normal)
    viewModel.editedImage.onNext(image)
  }
}

extension ProfileEditViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    textField.textColor = .black
    return range.location < 15
  }
}

extension ProfileEditViewController {
  
  enum Constants {
    static let nicknamePlaceholder = "한글, 영문, 숫자 포함 8글자로 입력가능해요."
    static let nicknameAlertMessage = "닉네임 변경은 한번만 가능해요"
    static let introduction = "소개"
    static let introductionPlaceholder = "소개하는 내용을 입력해주세요"
  }
  
}
