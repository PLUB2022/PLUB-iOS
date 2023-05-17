// 
//  GetAnnouncementUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/17.
//

import RxSwift

protocol GetAnnouncementUseCase {
  func execute(nextCursorID: Int) -> Observable<(content: [AnnouncementContent], nextCursorID: Int, isLast: Bool)>
}

final class DefaultGetAnnouncementUseCase: GetAnnouncementUseCase {
  
  private let plubbingID: Int
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
  }
  
  func execute(nextCursorID: Int = 0) -> Observable<(content: [AnnouncementContent], nextCursorID: Int, isLast: Bool)> {
    Observable<PaginatedDataResponse<AnnouncementContent>>.just(
      PaginatedDataResponse<AnnouncementContent>.init(
        totalElements: 10,
        isLast: true,
        content: [AnnouncementContent](repeating: AnnouncementContent.mockUp, count: 10)
      )
    )
    .map { data in
      (
        content: data.content,
        nextCursorID: data.content.last?.noticeID ?? 0,
        isLast: data.isLast
      )
      
    }
  }
}
