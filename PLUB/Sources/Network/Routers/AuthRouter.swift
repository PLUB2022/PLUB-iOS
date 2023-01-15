//
//  AuthRouter.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/16.
//

import Alamofire

enum AuthRouter {
  case socialLogin(type: SignInType, token: String?, authorizationCode: String?)
}
