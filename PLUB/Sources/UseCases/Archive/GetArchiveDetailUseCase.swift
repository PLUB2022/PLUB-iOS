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
  private let archiveID: Int?
  
  init(plubbingID: Int, archiveID: Int?) {
    self.plubbingID = plubbingID
    self.archiveID  = archiveID
  }
  
  func execute() -> Observable<ArchiveContent> {
    guard let archiveID else { return .error(PLUBError<GeneralResponse<ArchiveContent>>.unknownedError) }
    return ArchiveService.shared.fetchArchiveDetails(plubbingID: plubbingID, archiveID: archiveID)
  }
}
