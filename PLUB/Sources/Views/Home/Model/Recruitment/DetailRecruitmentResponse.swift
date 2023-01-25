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
    
    self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    self.introduce = try values.decodeIfPresent(String.self, forKey: .introduce) ?? ""
    self.categories = try values.decodeIfPresent([String].self, forKey: .categories) ?? []
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.goal = try values.decodeIfPresent(String.self, forKey: .goal) ?? ""
    self.mainImage = try values.decodeIfPresent(String.self, forKey: .mainImage) 
    self.days = try values.decodeIfPresent([String].self, forKey: .days) ?? []
    self.time = try values.decodeIfPresent(String.self, forKey: .time) ?? ""
    self.address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
    self.roadAddress = try values.decodeIfPresent(String.self, forKey: .roadAddress) ?? ""
    self.placeName = try values.decodeIfPresent(String.self, forKey: .placeName) ?? ""
    self.placePositionX = try values.decodeIfPresent(Double.self, forKey: .placePositionX) ?? 0.0
    self.placePositionY = try values.decodeIfPresent(Double.self, forKey: .placePositionY) ?? 0.0
    self.isBookmarked = try values.decodeIfPresent(Bool.self, forKey: .isBookmarked) ?? false
    self.isApplied = try values.decodeIfPresent(Bool.self, forKey: .isApplied) ?? false
    self.curAccountNum = try values.decodeIfPresent(Int.self, forKey: .curAccountNum) ?? 0
    self.remainAccountNum = try values.decodeIfPresent(Int.self, forKey: .remainAccountNum) ?? 0
    self.joinedAccounts = try values.decodeIfPresent([AccountInfo].self, forKey: .joinedAccounts) ?? []
  }
}

struct AccountInfo: Codable {
  let accountId: Int
  let profileImage: String?
}
