//
//  ImageRouter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/25.
//

import Alamofire

enum ImageRouter {
  case uploadImage
  case updateImage
  case deleteImage
}

extension ImageRouter: Router {
  
  var method: HTTPMethod {
    switch self {
    case .uploadImage, .updateImage:
      return .post
    case .deleteImage:
      return .delete
    }
  }
  
  var path: String {
    switch self {
    case .uploadImage:
      return "/files"
    case .updateImage:
      return "/files/change"
    case .deleteImage:
      return "/api/files"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .uploadImage:
      return .plain
    case .updateImage:
      return .plain
    case .deleteImage:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .uploadImage, .updateImage:
      return .formData
    case .deleteImage:
      return .withAccessToken
    }
  }
}
