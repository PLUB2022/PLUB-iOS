//
//  RegisterInterestRequest.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/11.
//

import Foundation

/// 관심사 등록 요청 모델
struct RegisterInterestRequest: Encodable {
  /// 서브 카테고리
  let subCategories: [Int]
}
