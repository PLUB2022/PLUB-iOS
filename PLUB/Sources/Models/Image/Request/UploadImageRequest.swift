//
//  UploadImageRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/25.
//

/// 이미지 업로드 요청값
struct UploadImageRequest: Codable {
  
  /// 타입 설정
  let type: ImageType
}

enum ImageType: String, Codable {
  
  /// 프로필 이미지
  case profile
  
  /// 플러빙 메인 이미지
  case plubbingMain = "plubbing-main"
  
  /// 게시판 이미지
  case feed
}
