//
//  RegisterInterestCollectionViewCellModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/01.
//

import Foundation

struct RegisterInterestModel {
  let interestCollectionSectionType: InterestCollectionType
  let interestDetailTypes: [InterestCollectionType]
  var isExpanded: Bool
  
  init(interestCollectionType: InterestCollectionType, interestDetailTypes: [InterestCollectionType], isExpanded: Bool = false) {
    self.interestCollectionSectionType = interestCollectionType
    self.interestDetailTypes = interestDetailTypes
    self.isExpanded = isExpanded
  }
}

enum InterestCollectionType: CaseIterable {
  case Art
  case SportFitness
  case Investment
  case LanguageStudy
  case Culture
  case Food
  case Employment
  case Computer
  
  var title: String {
    switch self {
    case .Art:
      return "예술"
    case .SportFitness:
      return "스포츠/피트니스"
    case .Investment:
      return "재테크/투자"
    case .LanguageStudy:
      return "어학"
    case .Culture:
      return "문화"
    case .Food:
      return "음식"
    case .Employment:
      return "취업/창업"
    case .Computer:
      return "컴퓨터"
    }
  }
  
  var imageNamed: String {
    switch self {
    case .Art:
      return "art"
    case .SportFitness:
      return "sport"
    case .Investment:
      return "money"
    case .LanguageStudy:
      return "language"
    case .Culture:
      return "movie"
    case .Food:
      return "food"
    case .Employment:
      return "work"
    case .Computer:
      return "computer"
    }
  }
}
