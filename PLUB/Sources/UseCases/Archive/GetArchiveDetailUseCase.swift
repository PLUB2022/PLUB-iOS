//
//  GetArchiveDetailUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/16.
//

import RxSwift

protocol GetArchiveDetailUseCase {
  func execute() -> Observable<ArchiveContent>
}

final class DefaultGetArchiveDetailUseCase: GetArchiveDetailUseCase {
  
  private let plubbingID: Int
  private let archiveID: Int
  
  init(plubbingID: Int, archiveID: Int) {
    self.plubbingID = plubbingID
    self.archiveID  = archiveID
  }
  
  func execute() -> Observable<ArchiveContent> {
    ArchiveService.shared.fetchArchiveDetails(plubbingID: plubbingID, archiveID: archiveID)
  }
}
