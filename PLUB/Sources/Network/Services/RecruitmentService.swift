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
  func inquireDetailRecruitment(plubbingId: String) -> Observable<NetworkResult<GeneralResponse<DetailRecruitmentResponse>>> {
    return sendRequest(RecruitmentRouter.inquireDetailRecruitment(plubbingId), type: DetailRecruitmentResponse.self)
  }
  
  func inquireRecruitmentQuestion(plubbingId: String) -> Observable<NetworkResult<GeneralResponse<RecruitmentQuestionResponse>>> {
    return sendRequest(RecruitmentRouter.inquireRecruitmentQuestion(plubbingId), type: RecruitmentQuestionResponse.self)
  }
}
