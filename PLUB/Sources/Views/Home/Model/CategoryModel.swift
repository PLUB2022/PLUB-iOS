//
//  CategoryModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/04/06.
//

import Foundation

/// `CategoryModel`과 `SubCategoryStatus`모델은 기존 API 응답모델과는 별개의 모델로써
/// 각각 모델의 역할을 분담하기위해 분리해두었습니다
struct CategoryModel {
  
  /// 카테고리에 대한 아이디
  let id: Int
  
  /// 카테고리 이름
  let name: String
  
  /// 카테고리 아이콘 이미지 문자열 값
  let icon: String
  
  /// 각각의 서브카테고리에 해당하는 상태값
  /// 기존 API를 통해 받아온 SubCategory에서 선택되었는지에 대한 상태값인 `isSelected`값이 추가되었습니다
  /// `isSelected`값을 통해 관심사 등록시 선택여부를 확인합니다
  var subCategories: [SubCategoryStatus]
  
  init(category: Category) {
    id = category.id
    name = category.name
    icon = category.icon
    subCategories = category.subCategories.map { SubCategoryStatus(subCategory: $0) }
  }
}

struct SubCategoryStatus {
  
  /// 서브카테고리에 대한 아이디
  let id: Int
  
  /// 서브카테고리 이름
  let name: String
  
  /// 서브카테고리가 해당하는 카테고리의 이름
  let categoryName: String
  
  /// 서브카테고리가 해당하는 카테고리의 아이디
  let parentID: String
  
  /// 해당 서브카테고리가 선택되었는지에 대한 상태값
  var isSelected: Bool
  
  init(subCategory: SubCategory) {
    id = subCategory.id
    name = subCategory.name
    categoryName = subCategory.categoryName
    parentID = subCategory.parentID
    isSelected = false
  }
}
