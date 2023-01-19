//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

class HomeService: BaseService {
  static let shared = HomeService()
  
  private override init() { }
}

extension HomeService {
  func inquireMainCategoryList() -> Observable<NetworkResult<GeneralResponse<MainCategoryListResponse>>> {
    return sendRequest(CategoryRouter.inquireMainCategoryList, type: MainCategoryListResponse.self)
  }
  
  func inquireAll() -> Observable<NetworkResult<GeneralResponse<AllCategoryListResponse>>> {
    return sendRequest(CategoryRouter.inquireAll, type: AllCategoryListResponse.self)
  }
  
  func inquireSubCategoryList(categoryId: Int) -> Observable<NetworkResult<GeneralResponse<SubCategoryListResponse>>> {
    return sendRequest(CategoryRouter.inquireSubCategoryList(categoryId), type: SubCategoryListResponse.self)
  }
}
