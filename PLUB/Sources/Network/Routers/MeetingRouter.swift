//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case inquireCategoryMeeting(Int, MeetingQuery)
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireCategoryMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireCategoryMeeting(let categoryId, _):
      return "/plubbings/categories/\(categoryId)"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireCategoryMeeting(_, let query):
      return .query(query)
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireCategoryMeeting:
      return .withAccessToken
    }
  }
}

struct MeetingQuery: Encodable {
  let page: Int
  
  enum CodingKeys: String, CodingKey {
    case page
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(page, forKey: .page)
  }
}
