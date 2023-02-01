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
  
  /// Splash화면 이후 보여줄 ViewController를 emit할 `Subject`
  private let moveVCSubject = PublishSubject<UIViewController>()
  
  init() {
    shouldMoveToVC = moveVCSubject.asDriver(onErrorDriveWith: .empty())
    
    bind()
  }
  
  private func bind() {
    
  }
  
}
