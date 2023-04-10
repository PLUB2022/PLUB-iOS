//
//  DetailRecruitmentResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import Foundation

/// 모집 글 상세 조회 응답 모델
struct DetailRecruitmentResponse: Codable {
  
  /// 모집하는 플러빙의 제목
  let title: String
  
  /// 플러빙의 소개
  let introduce: String
  
  /// 플러빙의 카테고리
  let categories: [String]
  
  /// 플러빙 이름
  let name: String
  
  /// 플러빙 목표
  let goal: String
  
  /// 플러빙 대표 이미지
  ///
  /// 이미지 주소(URL Link)로 응답을 받습니다.
  let mainImage: String?
  
  /// 플러빙 모임 요일
  let days: [Day]
  
  /// 플러빙 모임 시간
  ///
  /// `hh:mm`형식으로 값이 들어옵니다.
  let time: String
  
  /// 플러빙 모임 주소
  let address: String
  
  /// 플러빙 모임 도로명 주소
  let roadAddress: String
  
  /// 플러빙 모임 장소의 이름
  let placeName: String
  
  /// 플러빙 모임 위치 중 위도
  let placePositionX: Double
  
  /// 플러빙 모임 위치 중 경도
  let placePositionY: Double
  
  /// 해당 플러빙의 북마크처리 여부
  let isBookmarked: Bool
  
  /// 이미 해당 플러빙의 일원인지 판단합니다.
  let isApplied: Bool
  
  /// 플러빙의 최근 참여자 인원 수
  let curAccountNum: Int
  
  /// 플러빙의 남은 인원 수
  ///
  /// 앞으로 몇 명을 더 받을지를 나타내는 변수입니다. 만약 20명을 뽑는데, 이미 16명이 참여자로 들어가있다면, 해당 값은 `4`가 됩니다.
  let remainAccountNum: Int
  
  /// 참여자 인원 목록
  let joinedAccounts: [AccountInfo]
  
  enum CodingKeys: String, CodingKey {
    case title, introduce, categories, name, goal, mainImage, days, time, address, roadAddress, placeName, placePositionX, placePositionY, isBookmarked, isApplied, curAccountNum, remainAccountNum, joinedAccounts
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    introduce = try values.decodeIfPresent(String.self, forKey: .introduce) ?? ""
    categories = try values.decodeIfPresent([String].self, forKey: .categories) ?? []
    name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    goal = try values.decodeIfPresent(String.self, forKey: .goal) ?? ""
    mainImage = try values.decodeIfPresent(String.self, forKey: .mainImage)
    days = try values.decodeIfPresent([Day].self, forKey: .days) ?? []
    time = try values.decodeIfPresent(String.self, forKey: .time) ?? ""
    address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
    roadAddress = try values.decodeIfPresent(String.self, forKey: .roadAddress) ?? ""
    placeName = try values.decodeIfPresent(String.self, forKey: .placeName) ?? ""
    placePositionX = try values.decodeIfPresent(Double.self, forKey: .placePositionX) ?? 0.0
    placePositionY = try values.decodeIfPresent(Double.self, forKey: .placePositionY) ?? 0.0
    isBookmarked = try values.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
    isApplied = try values.decodeIfPresent(Bool.self, forKey: .isApplied) ?? false
    curAccountNum = try values.decodeIfPresent(Int.self, forKey: .curAccountNum) ?? 0
    remainAccountNum = try values.decodeIfPresent(Int.self, forKey: .remainAccountNum) ?? 0
    joinedAccounts = try values.decodeIfPresent([AccountInfo].self, forKey: .joinedAccounts) ?? []
  }
}

// MARK: - AccountInfo

/// 플러빙 참여 인원의 간략한 계정 정보 모델
struct AccountInfo: Codable {
  
  /// 계정 ID
  let accountId: Int
  
  /// 프로필 이미지
  let profileImage: String?
  
  /// 닉네임
  let nickname: String
}
