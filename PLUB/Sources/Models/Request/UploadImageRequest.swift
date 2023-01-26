//
//  UploadImageRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/25.
//

/// 이미지 업로드 요청값
struct UploadImageRequest: Codable {
  
  /// 타입 설정
  let type: String
}

enum ImageType {
  
  /// 프로필 이미지
  case profile
  
  /// 플러빙 메인 이미지
  case plubbingMain
}

extension ImageType {
  
  var value: String {
    switch self {
    case .profile:
      return "profile"
      
    case .plubbingMain:
      return "plubbing-main"
    }
  }
}
