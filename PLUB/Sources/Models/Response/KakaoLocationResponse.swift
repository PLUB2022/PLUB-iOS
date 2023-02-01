//
//  KakaoLocationResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/20.
//

struct KakaoLocationResponse: Codable {
  var documents: [KakaoLocationDocuments]
  var meta: KakaoLocationMeta
}

struct KakaoLocationDocuments: Codable {
  var address: String?
  var placeName: String?
  var roadAddress: String?
  var placePositionX: String?
  var placePositionY: String?
  
  enum CodingKeys: String, CodingKey {
    case address = "address_name"
    case placeName = "place_name"
    case roadAddress = "road_address_name"
    case placePositionX = "x"
    case placePositionY = "y"
  }
}

struct KakaoLocationMeta: Codable {
  var isEnd: Bool
  var totalCount: Int
  
  enum CodingKeys: String, CodingKey {
    case isEnd = "is_end"
    case totalCount = "pageable_count"
  }
}
