// 
//  EditArchiveUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import RxSwift

protocol EditArchiveUseCase {
  func execute(title: String, images: [String]) -> Observable<BaseService.EmptyModel>
}

final class DefaultEditArchiveUseCase: EditArchiveUseCase {
  
  private let plubbingID: Int
  private let archiveID: Int
  
  init(plubbingID: Int, archiveID: Int) {
    self.plubbingID = plubbingID
    self.archiveID  = archiveID
  }
  
  func execute(title: String, images: [String]) -> Observable<BaseService.EmptyModel> {
    ArchiveService.shared.updateArchive(
      plubbingID: plubbingID,
      archiveID: archiveID,
      model: ArchiveRequest(title: title, images: images)
    )
    .map { _ in .init() }
  }
}
