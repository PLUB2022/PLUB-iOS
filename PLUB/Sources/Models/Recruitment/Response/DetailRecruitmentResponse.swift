//
//  DetailRecruitmentResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import Foundation

struct DetailRecruitmentResponse: Codable {
    let title: String
    let introduce: String
    let categories: [String]
    let name: String
    let goal: String
    let mainImage: String?
    let days: [String]
    let time: String
    let address: String
    let roadAddress: String
    let placeName: String
    let placePositionX: Double
    let placePositionY: Double
    let isBookmarked: Bool
    let isApplied: Bool
    let curAccountNum: Int
    let remainAccountNum: Int
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
    days = try values.decodeIfPresent([String].self, forKey: .days) ?? []
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

struct AccountInfo: Codable {
  let accountId: Int
  let profileImage: String?
  let nickname: String
}
