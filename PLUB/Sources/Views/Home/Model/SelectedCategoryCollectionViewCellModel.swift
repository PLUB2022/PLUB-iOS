//
//  SelectedCategoryCollectionViewCellModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/04/06.
//

import Foundation

struct SelectedCategoryCollectionViewCellModel { // 차트, 그리드일때 둘 다 동일한 모델
  let plubbingID: Int
  let name: String
  let title: String
  let mainImage: String?
  let introduce: String
  var isBookmarked: Bool
  let selectedCategoryInfoModel: CategoryInfoListModel
  let isHost: Bool
  
  init(content: Content) {
    plubbingID = content.plubbingID
    name = content.name
    title = content.title
    mainImage = content.mainImage
    introduce = content.introduce
    isBookmarked = content.isBookmarked
    selectedCategoryInfoModel = .init(
      placeName: content.placeName,
      peopleCount: content.remainAccountNum,
      dateTime: content.days
        .map { $0.kor }
        .joined(separator: ",")
      + " | "
      + "(data.time)")
    isHost = content.isHost
  }
  
  init(content: CategoryContent) {
    plubbingID = content.plubbingID
    name = content.name
    title = content.title
    mainImage = content.mainImage
    introduce = content.introduce
    isBookmarked = content.isBookmarked
    selectedCategoryInfoModel = .init(
      placeName: content.placeName,
      peopleCount: content.remainAccountNum,
      dateTime: content.days
        .map { $0.kor }
        .joined(separator: ",")
      + " | "
      + "(data.time)")
    isHost = false
  }
}
