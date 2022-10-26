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
    
    self.view.addSubview(stackView)
    
    [appleLoginButton].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(40)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(164)
    }
    
    self.appleLoginButton.snp.makeConstraints { make in
      make.height.equalTo(44)
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
