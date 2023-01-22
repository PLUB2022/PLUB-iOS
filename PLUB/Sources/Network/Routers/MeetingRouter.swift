//
//  CategoryRouter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import Alamofire

enum MeetingRouter {
  case inquireCategoryMeeting(Int, Int)
  case inquireRecommendationMeeting
}

extension MeetingRouter: Router {
  var method: HTTPMethod {
    switch self {
    case .inquireCategoryMeeting, .inquireRecommendationMeeting:
      return .get
    }
  }
  
  var path: String {
    switch self {
    case .inquireCategoryMeeting(let categoryId, _):
      return "/plubbings/categories/\(categoryId)"
    case .inquireRecommendationMeeting:
      return "/plubbings/recommendation"
    }
  }
  
  var parameters: ParameterType {
    switch self {
    case .inquireCategoryMeeting(_, let page):
      return .query(["page": page])
    case .inquireRecommendationMeeting:
      return .plain
    }
  }
  
  var headers: HeaderType {
    switch self {
    case .inquireCategoryMeeting, .inquireRecommendationMeeting:
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
