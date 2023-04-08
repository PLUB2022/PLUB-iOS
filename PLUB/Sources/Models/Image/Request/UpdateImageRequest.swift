//
//  UpdateImageRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/08.
//

struct UpdateImageRequest: Codable {
  let type: ImageType
  let deleteURL: String
  
  enum CodingKeys: String, CodingKey {
    case type
    case deleteURL = "toDeleteUrls"
  }
}
