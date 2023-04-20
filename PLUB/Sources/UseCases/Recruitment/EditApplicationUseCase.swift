//
//  EditApplicationUseCase.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/21.
//

import RxSwift

protocol EditApplicationUseCase {
  func execute(
    plubbingID: Int,
    answer: [ApplyAnswer]
  ) -> Observable<Void>
}

final class DefaultEditApplicationUseCase: EditApplicationUseCase {
  func execute(
    plubbingID: Int,
    answer: [ApplyAnswer]
  ) -> Observable<Void> {
    RecruitmentService.shared.editApplication(
      plubbingID: plubbingID,
      request: ApplyForRecruitmentRequest(answers: answer)
    )
    .map { _ in () }
  }
}
