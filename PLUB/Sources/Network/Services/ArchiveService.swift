// 
//  ArchiveService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/10.
//

import Foundation

import RxSwift
import RxCocoa

final class ArchiveService: BaseService {
  static let shared = ArchiveService()
  
  private override init() { }
}

extension ArchiveService {
  
  
  /// 아카이브를 생성합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - title: 아카이브 제목
  ///   - images: 만든 이미지
  func createArchive(plubbingID: Int, title: String, images: [String]) -> Observable<CreateArchiveResponse> {
    sendObservableRequest(
      ArchiveRouter.createArchive(
        plubbingID: plubbingID,
        model: CreateArchiveRequest(title: title, images: images)
      )
    )
  }
  
  /// 아카이브를 조회합니다.
  /// - Parameters:
  ///   - plubbingID: 플러빙 ID
  ///   - nextCursorID: 다음 아카이브를 조회할 때 사용할 커서 ID
  func fetchArchives(plubbingID: Int, nextCursorID: Int = 0) -> Observable<PaginatedDataResponse<FetchArchiveResponse>> {
    sendObservableRequest(ArchiveRouter.fetchArchives(plubbingID: plubbingID, cursorID: nextCursorID))
  }
  
  /// 아카이브 상세 조회 시 사용됩니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - archiveID: 아카이브 ID
  func fetchArchiveDetails(plubbingID: Int, archiveID: Int) -> Observable<FeedsContent> {
    sendObservableRequest(ArchiveRouter.fetchArchiveDetails(plubbingID: plubbingID, archiveID: archiveID))
  }
  
  /// 아카이브를 수정합니다.
  /// - Parameters:
  ///   - plubbingID: 플럽 모임 ID
  ///   - archiveID: 아카이브 ID
  ///   - model: 아카이브 모델
  func updateArchive(plubbingID: Int, archiveID: Int, model: CreateArchiveRequest) -> Observable<BoardsResponse> {
    sendObservableRequest(
      ArchiveRouter.updateArchive(
        plubbingID: plubbingID,
        archiveID: archiveID,
        model: model
      )
    )
  }
}
