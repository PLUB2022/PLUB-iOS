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
  case deleteImage(String, ImageType)
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
    case let .deleteImage(_, imageType):
      return "/files/\(imageType.rawValue)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .uploadImage, .updateImage:
      return .plain
    case let .deleteImage(fileURL, _):
      return .query(["fileUrl": fileURL])
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
