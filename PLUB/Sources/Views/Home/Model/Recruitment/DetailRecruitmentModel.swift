//
//  DetailRecruitmentModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/23.
//

import Foundation

struct DetailRecruitmentModel {
  let title: String
  let introduce: String
  let categories: [String]
  let name: String
  let goal: String
  let mainImage: String?
  let days: [String]
  let placeName: String
  let isBookmarked: Bool
  let isApplied: Bool
  let joinedAccounts: [AccountInfo]
  
  init(response: DetailRecruitmentResponse) {
    self.title = response.title
    self.introduce = response.introduce
    self.categories = response.categories
    self.name = response.name
    self.goal = response.goal
    self.mainImage = response.mainImage
    self.days = response.days
    self.placeName = response.placeName
    self.isBookmarked = response.isBookmarked
    self.isApplied = response.isApplied
    self.joinedAccounts = response.joinedAccounts
  }
}
