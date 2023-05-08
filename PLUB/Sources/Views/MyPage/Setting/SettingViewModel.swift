//
//  SettingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/09.
//


import Foundation

import RxSwift
import RxCocoa

protocol SettingViewModelType {
  // MARK: Property

  // MARK: Input
  var logoutButtonTapped: AnyObserver<Void> { get }
  
  // MARK: Output
  var successLogout: Driver<Void> { get }
}

final class SettingViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: UseCase
  private let logoutUseCase: LogoutUseCase
  
  // MARK: Subjects
  private let logoutButtonTappedSubject = PublishSubject<Void>()
  private let successLogoutSubject = PublishSubject<Void>()
  
  init(logoutUseCase: LogoutUseCase) {
    self.logoutUseCase = logoutUseCase
    
    setupLogout()
  }
  
  private func setupLogout() {
    logoutButtonTappedSubject
      .flatMap { [logoutUseCase] in
        logoutUseCase.execute()
          .map { _ in () }
      }
      .bind(to: successLogoutSubject)
      .disposed(by: disposeBag)
  }
}

extension SettingViewModel: SettingViewModelType {
  // MARK: Input
  var logoutButtonTapped: AnyObserver<Void> {
    logoutButtonTappedSubject.asObserver()
  }
  
  // MARK: Output
  var successLogout: Driver<Void> { successLogoutSubject.asDriver(onErrorDriveWith: .empty())
  }
}
