//
//  AccountService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/21.
//

import Foundation

import RxCocoa
import RxSwift

final class AccountService: BaseService {
  static let shared = AccountService()
  
  private override init() { }
}

extension AccountService {
  func validateNickname(_ nickname: String) -> PLUBResult<EmptyModel> {
    return sendRequest(AccountRouter.validateNickname(nickname))
  }
  
  func inquireInterest() -> PLUBResult<InquireInterestResponse> {
    return sendRequest(AccountRouter.inquireInterest, type: InquireInterestResponse.self)
  }
  
  func registerInterest(request: RegisterInterestRequest) -> PLUBResult<EmptyModel> {
    return sendRequest(AccountRouter.registerInterest(request))
  }
}
