//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum CategoryRouter {
  case inquireMainCategoryList
  case inquireAll
  case inquireSubCategoryList
}

extension CategoryRouter: Router {
  
}
