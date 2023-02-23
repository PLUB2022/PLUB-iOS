//
//  FeedsClipboardResponse.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

struct FeedsClipboardResponse: Codable {
  let data: PinnedFeedList
}


extension FeedsClipboardResponse {
  struct PinnedFeedList: Codable {
    let pinnedFeedList: [FeedsContent]
    
    enum CodingKeys: String, CodingKey {
      case pinnedFeedList = "pinedFeedList"
    }
  }
}
