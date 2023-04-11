//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

class CategoryService: BaseService {
  static let shared = CategoryService()
  
  private override init() { }
}

extension CategoryService {
  func inquireMainCategoryList() -> PLUBResult<MainCategoryListResponse> {
    return sendRequest(CategoryRouter.inquireMainCategoryList, type: MainCategoryListResponse.self)
  }
  
  func inquireAll() -> PLUBResult<AllCategoryListResponse> {
    return sendRequest(CategoryRouter.inquireAll, type: AllCategoryListResponse.self)
  }
  
  func inquireSubCategoryList(categoryID: Int) -> PLUBResult<SubCategoryListResponse> {
    return sendRequest(CategoryRouter.inquireSubCategoryList(categoryID), type: SubCategoryListResponse.self)
  }
}
