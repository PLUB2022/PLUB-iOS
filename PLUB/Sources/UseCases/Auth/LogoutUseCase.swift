//
//  LogoutUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/09.
//

import RxSwift

protocol LogoutUseCase {
  func execute() -> Observable<BaseService.EmptyModel>
}

final class DefaultLogoutUseCase: LogoutUseCase {
  
  func execute() -> Observable<BaseService.EmptyModel> {
    AuthService.shared.logout()
  }
}
