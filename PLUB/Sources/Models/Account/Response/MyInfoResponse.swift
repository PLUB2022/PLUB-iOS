//
//  MyInfoResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import Foundation

/// 내 정보 조회 응답 모델
struct MyInfoResponse: Codable {
  /// 내 이메일
  let email: String
  
  /// 내 닉네임
  let nickname: String
  
  /// 내 로그인 소셜 타입
  let socialType: SocialType
  
  /// 내 생일, `yyyy-MM-dd` 형태의 문자열로 형성
  let birthday: String
  
  /// 내 성별
  let gender: Sex
  
  /// 나의 소개
  let introduce: String
  
  /// 나의 프로필 이미지, 등록하지 않았다면 `nil`을 갖습니다.
  let profileImage: String?
}
