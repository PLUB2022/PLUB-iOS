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
  private let moveVCRelay = ReplayRelay<UIViewController>.create(bufferSize: 1)
  
  private let disposeBag = DisposeBag()
  
  init() {
    shouldMoveToVC = moveVCRelay.asDriver(onErrorDriveWith: .empty())
    
    bind()
  }
  
  private func bind() {
    guard let isLaunchedBefore = UserManager.shared.isLaunchedBefore,
          isLaunchedBefore == true
    else {
      moveVCRelay.accept(OnboardingViewController()) // 온보딩으로 띄움
      return
    }
    
    UserManager.shared.reissuanceAccessToken()
      .map { _ in HomeViewController(viewModel: HomeViewModel()) }  // 토큰 재발급 성공한 경우 Home으로 이동할 준비
      .catchAndReturn(LoginViewController())                        // 토큰 재발급 실패한 경우 Login창으로 이동
      .bind(to: moveVCRelay)
      .disposed(by: disposeBag)
  }
}
