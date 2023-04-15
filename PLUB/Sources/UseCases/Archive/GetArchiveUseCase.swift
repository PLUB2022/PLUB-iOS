//
//  GetArchiveUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/15.
//

import RxSwift

protocol GetArchiveUseCase {
  func execute(
    plubbingID: Int,
    nextCursorID: Int
  ) -> Observable<(content: [ArchiveContent], nextCursorID: Int, isLast: Bool)>
}

final class DefaultGetArchiveUseCase: GetArchiveUseCase {
  func execute(
    plubbingID: Int,
    nextCursorID: Int = 0
  ) -> Observable<(content: [ArchiveContent], nextCursorID: Int, isLast: Bool)> {
    ArchiveService.shared.fetchArchives(plubbingID: plubbingID, nextCursorID: nextCursorID)
      .map { data in
        (
          content: data.content,
          nextCursorID: data.content.last?.archiveID ?? 0,
          isLast: data.isLast
        )
      }
  }
}
