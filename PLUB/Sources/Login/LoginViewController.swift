import AuthenticationServices
import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LoginViewController: BaseViewController {
  
  // MARK: - Property
  
  private let logoImageView: UIImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: AssetName.logo)
  }
  
  private let stackView: UIStackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private let termsLabel: UILabel = UILabel().then {
    $0.text = "가입을 진행할 경우, 서비스 약관 및\n개인정보 처리방침에 동의한 것으로 간주합니다."
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.font = .caption
  }
  
  private let kakaoLoginButton: UIButton = UIButton().then {
    $0.setImage(UIImage(named: AssetName.kakao), for: .normal)
  }
  
  private let googleLoginButton: UIButton = UIButton().then {
    $0.setImage(UIImage(named: AssetName.google), for: .normal)
  }
  
  private let appleLoginButton: UIButton = UIButton().then {
    $0.setImage(UIImage(named: AssetName.apple), for: .normal)
  }
  
  // MARK: - Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    [logoImageView, stackView, termsLabel].forEach {
      self.view.addSubview($0)
    }
    
    [kakaoLoginButton, googleLoginButton, appleLoginButton].forEach {
      self.stackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.logoImageView.snp.makeConstraints { make in
      make.horizontalEdges.equalToSuperview().inset(106)
      make.centerY.equalToSuperview().offset(-150)
    }
    
    self.stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(40)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(164)
    }
    
    self.termsLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(60)
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
    view.backgroundColor = .background
  }
  
  override func bind() {
    super.bind()
  }
}

extension LoginViewController {
  
  private enum AssetName {
    static let apple = "Apple Login"
    static let google = "Google Login"
    static let kakao = "Kakao Login"
    static let logo = "Logo"
  }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct LoginViewControllerPreview: PreviewProvider {
  static var previews: some View {
    LoginViewController().toPreview()
  }
}
#endif
