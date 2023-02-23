// 
//  FeedsService.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/22.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedsService: BaseService {
  static let shared = FeedsService()
  
  private override init() { }
}

extension FeedsService {
  
  /// 게시판 조회 API
  /// - Parameters:
  ///   - plubIdentifier: plub ID
  ///   - page: 페이지 위치, 기본값은 1입니다.
  func getBoards(plubIdentifier: String, page: Int = 1) -> Observable<NetworkResult<GeneralResponse<FeedsPaginatedDataResponse<FeedsContent>>>> {
    sendRequest(
      FeedsRouter.fetchBoard(plubID: plubIdentifier, page: page),
      type: FeedsPaginatedDataResponse<FeedsContent>.self
    )
  }
  
  func getClipBoards(plubIdentifier: String) -> Observable<NetworkResult<GeneralResponse<FeedsClipboardResponse>>> {
    sendRequest(
      FeedsRouter.fetchClipboard(plubID: plubIdentifier),
      type: FeedsClipboardResponse.self
    )
  }
}
