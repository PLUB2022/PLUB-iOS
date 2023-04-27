//
//  ArchiveUploadViewModelFactory.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/22.
//

import Foundation

import RxSwift

protocol ArchiveUploadViewModelFactory {
  static func make(plubbingID: Int, archiveID: Int?) -> ArchiveUploadViewModel
}

/// 아카이브 수정 시 필요한 ViewModel을 생성하는 Factory
final class ArchiveUploadViewModelWithEditFactory: ArchiveUploadViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, archiveID: Int?) -> ArchiveUploadViewModel {
    return ArchiveUploadViewModel(
      getArchiveDetailUseCase: DefaultGetArchiveDetailUseCase(plubbingID: plubbingID, archiveID: archiveID),
      uploadImageUseCase: DefaultUploadImageUseCase(),
      deleteImageUseCase: DefaultDeleteImageUseCase(),
      uploadArchiveUseCase: EditArchiveUseCaseAdapter(plubbingID: plubbingID, archiveID: archiveID)
    )
  }
  
  /// Edit use case를 UploadUseCase와 연결하기 위한 Adapter
  private class EditArchiveUseCaseAdapter: UploadArchiveUseCase {
    
    private let plubbingID: Int
    private let archiveID: Int?
    
    init(plubbingID: Int, archiveID: Int?) {
      self.plubbingID = plubbingID
      self.archiveID = archiveID
    }
    
    func execute(title: String, images: [String]) -> Observable<BaseService.EmptyModel> {
      guard let archiveID else { return .error(PLUBError<GeneralResponse<BaseService.EmptyModel>>.unknownedError) }
      return DefaultEditArchiveUseCase(plubbingID: plubbingID, archiveID: archiveID).execute(title: title, images: images)
    }
  }
}

/// 아카이브 업로드 시 필요한 ViewModel을 생성하는 Factory
final class ArchiveUploadViewModelWithUploadFactory: ArchiveUploadViewModelFactory {
  
  private init() { }
  
  static func make(plubbingID: Int, archiveID: Int? = nil) -> ArchiveUploadViewModel {
    return ArchiveUploadViewModel(
      getArchiveDetailUseCase: GetArchiveDetailUseCaseAdapter(),
      uploadImageUseCase: DefaultUploadImageUseCase(),
      deleteImageUseCase: DefaultDeleteImageUseCase(),
      uploadArchiveUseCase: DefaultUploadArchiveUseCase(plubbingID: plubbingID)
    )
  }
  
  /// GetArchiveDetailUseCase 어댑터
  private class GetArchiveDetailUseCaseAdapter: GetArchiveDetailUseCase {
    func execute() -> Observable<ArchiveContent> {
      .just(ArchiveContent(archiveID: nil, title: "", images: [], imageCount: 0, sequence: 0, postDate: "", accessType: .normal))
    }
  }
}
