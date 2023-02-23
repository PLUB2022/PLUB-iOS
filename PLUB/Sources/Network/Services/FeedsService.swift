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
  
  func createBoards(plubIdentifier: Int, model: BoardsRequest) -> Observable<NetworkResult<GeneralResponse<BoardsResponse>>> {
    sendRequest(
      FeedsRouter.createBoard(plubID: plubIdentifier, model: model),
      type: BoardsResponse.self
    )
  }
  
  /// 게시판 조회 API
  /// - Parameters:
  ///   - plubIdentifier: plub ID
  ///   - page: 페이지 위치, 기본값은 1입니다.
  func fetchBoards(plubIdentifier: Int, page: Int = 1) -> Observable<NetworkResult<GeneralResponse<FeedsPaginatedDataResponse<FeedsContent>>>> {
    sendRequest(
      FeedsRouter.fetchBoards(plubID: plubIdentifier, page: page),
      type: FeedsPaginatedDataResponse<FeedsContent>.self
    )
  }
  
  func fetchClipboards(plubIdentifier: Int) -> Observable<NetworkResult<GeneralResponse<FeedsClipboardResponse>>> {
    sendRequest(
      FeedsRouter.fetchClipboards(plubID: plubIdentifier),
      type: FeedsClipboardResponse.self
    )
  }
  
  func fetchFeedDetails(plubIdentifier: Int, feedIdentifier: Int) -> Observable<NetworkResult<GeneralResponse<FeedsDetailResponse>>> {
    sendRequest(
      FeedsRouter.fetchFeedDetails(plubID: plubIdentifier, feedID: feedIdentifier),
      type: FeedsDetailResponse.self
    )
  }
}
