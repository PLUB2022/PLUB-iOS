//
//  RegisterInterestCollectionViewCellModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/01.
//

import Foundation

struct RegisterInterestModel {
  var category: CategoryModel
  var isExpanded: Bool
  
  init(category: Category) {
    self.category = CategoryModel(category: category)
    isExpanded = false
  }
}

