import AuthenticationServices
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LoginViewController: BaseViewController {
  
  // MARK: - Property
  
  private let logoImageView = UIImageView().then {
    $0.backgroundColor = UIColor(hex: 0x945CDB)
  }
  
  private let stackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private let kakaoLoginButton = UIButton(type: .system).then {
    $0.backgroundColor = .systemYellow
  }
  
  private let googleLoginButton = UIButton(type: .system).then {
    $0.backgroundColor = .systemGray6
  }
  
  private let appleLoginButton = UIButton(type: .system).then {
    $0.backgroundColor = .black
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    self.view.addSubview(logoImageView)
    self.view.addSubview(stackView)
    
    [kakaoLoginButton, googleLoginButton, appleLoginButton].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.logoImageView.snp.makeConstraints { make in
      make.horizontalEdges.equalToSuperview().inset(106)
      make.height.equalTo(50)
      make.centerY.equalToSuperview().offset(-150)
    }
    
    self.stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(40)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(164)
    }
    
    // == Button's constraints ==
    [kakaoLoginButton, googleLoginButton, appleLoginButton].forEach {
      $0.snp.makeConstraints { make in
        make.height.equalTo(44)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
  }
  
  override func bind() {
    super.bind()
  }
}
