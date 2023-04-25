//
//  LoginViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2022/09/28.
//

import AuthenticationServices
import UIKit

import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
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
  
  private let loginStackView: UIStackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private let termsLabel: UILabel = UILabel().then {
    let generalText = "가입을 진행할 경우, 서비스 약관 및\n개인정보 처리방침에 동의한 것으로 간주합니다."
    
    let generalAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.black,
      .font: UIFont.caption
    ]
    let linkAttributes: [NSAttributedString.Key: Any] = [
      .underlineStyle: NSUnderlineStyle.single.rawValue,
      .foregroundColor: UIColor.main,
      .font: UIFont.caption
    ]
    let mutableString = NSMutableAttributedString()
    
    // generalAttributes(기본 스타일) 적용
    mutableString.append(NSAttributedString(string: generalText, attributes: generalAttributes))
    
    // 각 문자열의 range에 맞게 linkAttributes 적용
    mutableString.setAttributes(
      linkAttributes,
      range: (generalText as NSString).range(of: "서비스 약관")
    )
    mutableString.setAttributes(
      linkAttributes,
      range: (generalText as NSString).range(of: "개인정보 처리방침")
    )
    
    $0.attributedText = mutableString
    $0.textAlignment = .center
    $0.numberOfLines = 0
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
    [logoImageView, loginStackView, termsLabel].forEach {
      view.addSubview($0)
    }
    
    [kakaoLoginButton, googleLoginButton, appleLoginButton].forEach {
      loginStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    logoImageView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(106)
      $0.centerY.equalToSuperview().offset(-150)
    }
    
    loginStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(40)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(164)
    }
    
    termsLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(60)
    }
    
    // == Button's constraints ==
    [kakaoLoginButton, googleLoginButton, appleLoginButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(44)
      }
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
  }
  
  override func bind() {
    super.bind()
    
    // Kakao Login
    kakaoLoginButton.rx.tap
      .withUnretained(self)
      .subscribe { owner, _ in
        owner.kakaoLogin()
      }
      .disposed(by: disposeBag)
    
    // Google Login
    googleLoginButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.googleLogin()
      })
      .disposed(by: disposeBag)
    
    // Apple Login
    appleLoginButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.appleLogin()
      })
      .disposed(by: disposeBag)
  }
}


// MARK: - Login Logics

extension LoginViewController {
  
  private func kakaoLogin() {
    let loginClosure: (OAuthToken?, Error?) -> Void = { [weak self] oauthToken, error in
      if let error = error {
        // TODO: 승현 - 카카오톡 로그인 실패 Alert 띄우기
        print(error)
        return
      }
      // accessToken 추출
      guard let accessToken = oauthToken?.accessToken else { return }
      self?.requestPLUBTokens(socialType: .kakao, token: accessToken)
    }
    
    if UserApi.isKakaoTalkLoginAvailable() {
      // 카카오톡 로그인 api 호출 결과를 클로저로 전달
      UserApi.shared.loginWithKakaoTalk(completion: loginClosure)
    } else { // 웹으로 로그인 호출
      UserApi.shared.loginWithKakaoAccount(completion: loginClosure)
    }
  }
  
  private func googleLogin() {
    GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
      guard error == nil else { return }
      guard let result = result else { return }
      self?.requestPLUBTokens(socialType: .google, authorizationCode: result.serverAuthCode)
    }
  }
  
  private func appleLogin() {
    let provider = ASAuthorizationAppleIDProvider()
    let request = provider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
  
  private func requestPLUBTokens(socialType: SocialType, token: String? = nil, authorizationCode: String? = nil) {
    AuthService.shared.requestAuth(socialType: socialType, token: token, authorizationCode: authorizationCode)
      .subscribe(with: self) { owner, tokenData in
        
        guard let accessToken  = tokenData.accessToken,
              let refreshToken = tokenData.refreshToken
        else {
          fatalError("성공이면서 디코딩도 완료된 상태이면 토큰이 없을 수가 없음")
        }
        
        // accessToken, refreshToken 업데이트
        UserManager.shared.updatePLUBToken(accessToken: accessToken, refreshToken: refreshToken)
        
        // == Logging ==
        Log.notice("accessToken: \(accessToken)")
        Log.notice("refreshToken: \(refreshToken)")
        
        // 플럽 메인 화면으로 이동
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = PLUBTabBarController()
        
      } onError: { owner, error in
        guard let error = error as? PLUBError<GeneralResponse<SignInResponse>>,
              case let .requestError(response) = error,
              let signToken = response.data?.signToken
        else {
          // TODO: 승현 - PLUB 로그인 실패 Alert 띄우기
          return
        }
        // Signin token 업데이트 및 소셜로그인 타입 업데이트
        UserManager.shared.set(signToken: signToken)
        UserManager.shared.set(socialType: socialType)
        owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Assets Constants

extension LoginViewController {
  
  private enum AssetName {
    static let apple = "Apple Login"
    static let google = "Google Login"
    static let kakao = "Kakao Login"
    static let logo = "Logo"
  }
}

// MARK: - ASAuthorizationControllerDelegate

extension LoginViewController: ASAuthorizationControllerDelegate {
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let credentials as ASAuthorizationAppleIDCredential:
      let authorizationCode = String(decoding: credentials.authorizationCode!, as: UTF8.self)
      let identityToken = String(decoding: credentials.identityToken!, as: UTF8.self)
      
      self.requestPLUBTokens(socialType: .apple, token: identityToken, authorizationCode: authorizationCode)
      
    default:
      break
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // TODO: 승현 - 애플 로그인 에러 Alert 띄우기
    print("Failed!: \(error)")
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
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
