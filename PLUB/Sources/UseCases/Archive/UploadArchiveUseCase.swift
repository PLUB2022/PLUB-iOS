// 
//  UploadArchiveUseCase.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/24.
//

import RxSwift

protocol UploadArchiveUseCase {
  func execute(title: String, images: [String]) -> Observable<BaseService.EmptyModel>
}

final class DefaultUploadArchiveUseCase: UploadArchiveUseCase {
  
  private let plubbingID: Int
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
  }
  
  func execute(title: String, images: [String]) -> Observable<BaseService.EmptyModel> {
    ArchiveService.shared.createArchive(
      plubbingID: plubbingID,
      model: ArchiveRequest(title: title, images: images)
    )
    .map { _ in .init() }
  }
}
