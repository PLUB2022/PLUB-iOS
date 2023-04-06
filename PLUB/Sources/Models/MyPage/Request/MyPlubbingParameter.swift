//
//  MyPlubbingParameter.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/13.
//

import Foundation

/// 마이 페이지 모임 조회시 `Query`로 요청할 모델
struct MyPlubbingParameter: Encodable {
  
  /// 모임 상태
  let status: PlubbingStatusType
  
  /// 커서 ID
  let cursorID: Int
  
  enum CodingKeys: String, CodingKey {
    case status
    case cursorID = "cursorId"
  }
}
