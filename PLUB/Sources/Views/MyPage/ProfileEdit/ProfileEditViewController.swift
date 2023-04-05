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

final class ProfileEditViewController: BaseViewController {
  
  // MARK: - Property
  
  weak var delegate: SignUpChildViewControllerDelegate?
  
  private let viewModel = ProfileEditViewModel()
  
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
    setupNavigationBar()
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
    
    
    // textField의 clean button 구현
    (nicknameTextField.rightView as? UIButton)?.rx.tap
      .asDriver()
      .drive(with: self, onNext: { owner, _ in
        owner.nicknameTextField.text = ""
        owner.configureInitialUI()
      })
      .disposed(by: disposeBag)
    
    // 텍스트가 비어있으면 UI 회색 처리
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
    
    // ===  ViewModel Binding  ===
    
    // 빨리 입력하면 api가 여러번 호출되므로, 0.5초동안 입력 없을 시 데이터 emit
    nicknameTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .skip(1)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .filter { $0 != "" }
      .bind(to: viewModel.nicknameText)
      .disposed(by: disposeBag)
    
    // 닉네임 사용가능여부를 판단하고 UI 업데이트
    viewModel.isAvailableNickname
      .drive(with: self) { owner, flag in
        owner.updateNicknameValidationUI(isValid: flag)
        // 부모 뷰컨의 `확인 버튼` 활성화 처리
        owner.delegate?.checkValidation(index: 2, state: flag)
      }
      .disposed(by: disposeBag)
    
    viewModel.isAvailableNickname
      .filter { $0 }
      .withLatestFrom(nicknameTextField.rx.text.asDriver())
      .compactMap { $0 }
      .drive(with: self) { owner, nickname in
        // 사용가능한 닉네임 전달
        owner.delegate?.information(nickname: nickname)
      }
      .disposed(by: disposeBag)
    
    // 메시지 처리
    viewModel.alertMessage
      .drive(alertLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  /// 최초 상태의 UI를 설정합니다. (textField, label, bubble image 등)
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
  
  private func setupNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "backButton"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  @objc
  private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
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
    delegate?.information(profile: image) // 프로필 이미지 전달
  }
}

extension ProfileEditViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    delegate?.checkValidation(index: 2, state: false)
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
