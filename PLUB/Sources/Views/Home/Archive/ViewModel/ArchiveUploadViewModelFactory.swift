//
//  ArchiveUploadViewModelFactory.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/22.
//

import Foundation

import RxSwift

protocol ArchiveUploadViewModelFactory {
  static func make(plubbingID: Int, archiveID: Int) -> ArchiveUploadViewModel
}

/// 아카이브 수정 시 필요한 ViewModel을 생성하는 Factory
final class ArchiveUploadViewModelWithEditFactory: ArchiveUploadViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, archiveID: Int) -> ArchiveUploadViewModel {
    return ArchiveUploadViewModel(
      getArchiveDetailUseCase: DefaultGetArchiveDetailUseCase(plubbingID: plubbingID, archiveID: archiveID)
    )
  }
}

/// 아카이브 업로드 시 필요한 ViewModel을 생성하는 Factory
final class ArchiveUploadViewModelWithUploadFactory: ArchiveUploadViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, archiveID: Int = -1) -> ArchiveUploadViewModel {
    return ArchiveUploadViewModel(
      getArchiveDetailUseCase: GetArchiveDetailUseCaseAdapter()
    )
  }
  
  /// GetArchiveDetailUseCase 어댑터
  private class GetArchiveDetailUseCaseAdapter: GetArchiveDetailUseCase {
    func execute() -> Observable<ArchiveContent> {
      .just(ArchiveContent(archiveID: -1, title: "", images: [], imageCount: 0, sequence: 0, postDate: "", accessType: .normal))
    }
  }
}
