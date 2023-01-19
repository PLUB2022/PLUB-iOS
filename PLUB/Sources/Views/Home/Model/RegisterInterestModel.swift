//
//  RegisterInterestCollectionViewCellModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/01.
//

import Foundation

struct RegisterInterestModel {
  let category: Category
  var isExpanded: Bool
  
  init(category: Category) {
    self.category = category
    self.isExpanded = false
  }
}

