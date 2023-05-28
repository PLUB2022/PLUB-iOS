//
//  SearchParameter.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import Foundation

/// 모집 글을 검색할 때 query로 요청할 모델
struct SearchParameter: Encodable {
  
  /// 검색한 키워드
  let keyword: String
  
  /// 커서 아이디
  let cursorID: Int?
  
  /// 필터링 타입
  ///
  /// title(제목), name(모임 이름), mix(제목 + 글) 세 가지 중 하나로 기입됩니다.
  let type: String?
  
  /// 정렬 기준
  ///
  /// popular(인기순), 최신순(new) 중 하나로 기입됩니다.
  let sort: String
  
  enum CodingKeys: String, CodingKey {
    case cursorID = "cursorId"
    case keyword, type, sort
  }
  
  init(keyword: String, cursorID: Int? = 1, type: String? = "mix", sort: String = "popular") {
    self.keyword = keyword
    self.cursorID = cursorID
    self.type = type
    self.sort = sort
  }
}
