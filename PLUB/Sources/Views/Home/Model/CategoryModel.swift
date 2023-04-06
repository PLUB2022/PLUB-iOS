//
//  CategoryModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/04/06.
//

import Foundation

struct CategoryModel {
  let id: Int
  let name: String
  let icon: String
  var subCategories: [SubCategoryStatus]
  
  init(category: Category) {
    id = category.id
    name = category.name
    icon = category.icon
    subCategories = category.subCategories.map { SubCategoryStatus(subCategory: $0) }
  }
}

struct SubCategoryStatus {
  let id: Int
  let name: String
  let categoryName: String
  let parentId: String
  var isSelected: Bool
  
  init(subCategory: SubCategory) {
    id = subCategory.id
    name = subCategory.name
    categoryName = subCategory.categoryName
    parentId = subCategory.parentId
    isSelected = false
  }
}
