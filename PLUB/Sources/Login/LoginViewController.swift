import AuthenticationServices
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LoginViewController: BaseViewController {
  
  // MARK: - Property
  
  private let stackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private lazy var appleLoginButton = ASAuthorizationAppleIDButton(type: .default, style: .black)
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(stackView)
    
    [appleLoginButton].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.stackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(162)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .systemBackground
  }
  
  override func bind() {
    super.bind()
  }
}
