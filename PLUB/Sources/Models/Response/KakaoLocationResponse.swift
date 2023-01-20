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
    var address_name: String?
    var category_group_code: String?
    var category_group_name: String?
    var category_name: String?
    var distance: String?
    var id: String?
    var phone: String?
    var place_name: String?
    var place_url: String?
    var road_address_name: String?
    var x: String?
    var y: String?
}

struct KakaoLocationMeta: Codable {
    var is_end: Bool?
    var pageable_count: Int?
    var same_name: KakaoLocationSameName
    var total_count: Int?
}

struct KakaoLocationSameName: Codable {
    var keyword: String?
    var region: [KakaoLocationRegion]
    var selected_region: String?
}

struct KakaoLocationRegion: Codable {
    
}
