// 
//  DeleteArchiveUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/05/01.
//

import RxSwift

protocol DeleteArchiveUseCase {
  func execute(archiveID: Int) -> Observable<ArchiveContent>
}

final class DefaultDeleteArchiveUseCase: DeleteArchiveUseCase {
  
  let plubbingID: Int
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
  }
  
  func execute(archiveID: Int) -> Observable<ArchiveContent> {
    ArchiveService.shared.deleteArchive(plubbingID: plubbingID, archiveID: archiveID)
  }
}
