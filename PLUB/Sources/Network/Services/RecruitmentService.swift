//
//  CategoryService.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/19.
//

import RxSwift

class RecruitmentService: BaseService {
  static let shared = RecruitmentService()
  
  private override init() { }
}

extension RecruitmentService {
  func a(plubbingId: Int) {
    return sendRequest(RecruitmentRouter.inquireDetailRecruitment(plubbingId))
  }
}
