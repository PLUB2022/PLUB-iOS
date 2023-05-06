//
//  MyFeedResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/06.
//

import Foundation

struct MyFeedResponse: Codable {
  let plubbingInfo: PlubbingInfo
  let feedInfo: FeedInfo
  
  enum CodingKeys: String, CodingKey {
    case plubbingInfo
    case feedInfo = "myFeedList"
  }
}

struct FeedInfo: Codable {
  let totalElements: Int
  let last: Bool
  let feedList: [FeedsContent]
  
  enum CodingKeys: String, CodingKey {
    case totalElements, last
    case feedList = "content"
  }
}
