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
  let remainAccountNum: Int
  let joinedAccounts: [AccountInfo]
  
  init(response: DetailRecruitmentResponse) {
    title = response.title
    introduce = response.introduce
    categories = response.categories
    name = response.name
    goal = response.goal
    mainImage = response.mainImage
    days = response.days
    placeName = response.placeName
    isBookmarked = response.isBookmarked
    isApplied = response.isApplied
    remainAccountNum = response.remainAccountNum
    joinedAccounts = response.joinedAccounts
  }
}
