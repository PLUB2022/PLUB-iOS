//
//  SplashViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/01.
//

import UIKit

import RxSwift
import RxCocoa

protocol SplashViewModelType: SplashViewModel {
  
  // Output
  var shouldMoveToVC: Driver<UIViewController> { get }
}

final class SplashViewModel: SplashViewModelType {
  
  // Output
  let shouldMoveToVC: Driver<UIViewController> // 이동할 ViewController를 받음
  
  /// Splash화면 이후 보여줄 ViewController를 emit할 `Relay`
  private let moveVCRelay = BehaviorRelay<UIViewController>(value: UIViewController())
  
  private let disposeBag = DisposeBag()
  
  init() {
    shouldMoveToVC = moveVCRelay.asDriver()
    
    bind()
  }
  
  private func bind() {
    guard let isLaunchedBefore = UserManager.shared.isLaunchedBefore,
          isLaunchedBefore == true
    else {
      UserManager.shared.set(isLaunchedBefore: true) // 최초 실행 로직을 탔으므로 true로 설정
      moveVCRelay.accept(OnboardingViewController()) // 온보딩으로 띄움
      return
    }
    
    let reissueTokens = UserManager.shared.reissuanceAccessToken().share()
    
    reissueTokens
      .filter { $0 } // 토큰 재발급 성공한 경우
      .map { _ in HomeViewController(viewModel: HomeViewModel()) } // Home으로 이동할 준비
      .bind(to: moveVCRelay)
      .disposed(by: disposeBag)
    
    reissueTokens
      .filter { $0 == false } // 토큰 재발급 실패한 경우
      .map { _ in LoginViewController() }
      .bind(to: moveVCRelay)
      .disposed(by: disposeBag)
  }
}
