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
}
