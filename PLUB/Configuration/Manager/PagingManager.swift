//
//  PagingManager.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/31.
//

import UIKit

import RxSwift
import RxCocoa

/// 페이징 처리를 위한 관리자 클래스 입니다.
final class PagingManager<T> {
  
  /// API 호출 중인지 판단합니다.
  private var isFetching = false
  
  /// 이미 마지막 페이지에 도달했는지 여부를 판단합니다.
  private(set) var isLast = false
  
  /// 임계값입니다. 마지막 셀로부터 `threshold`번째 앞인 셀이 보이는 경우 Fetch 조건에 해당하게 됩니다.
  private var threshold: Int
  
  /// 다음 요청할 커서의 `Identifier`입니다.
  private var nextCursorID = 0
  
  init(threshold: Int) {
    self.threshold = threshold
  }
  
  /// 다음 페이지를 가져올지 여부를 결정합니다.
  ///
  /// - Parameters:
  ///   - currentIndex: 현재 아이템의 인덱스입니다.
  ///   - totalItems: 전체 아이템 개수입니다.
  /// - Returns: 다음 페이지를 가져올지 여부를 반환합니다.
  func shouldFetchNextPage(currentIndex: Int, totalItems: Int) -> Bool {
    return !isFetching && !isLast && totalItems - currentIndex <= threshold
  }
  
  /// 다음 페이지를 가져옵니다.
  ///
  /// - Parameter fetch: 다음 페이지를 가져오는 함수입니다. 커서 ID를 입력으로 받고, 컨텐츠, 다음 커서 ID, 마지막 페이지 여부를 반환합니다.
  /// - Returns: 다음 페이지의 컨텐츠를 반환하는 `Observable`입니다.
  func fetchNextPage(fetch: @escaping (Int) -> Observable<(content: [T], nextCursorID: Int, isLast: Bool)>) -> Observable<[T]> {
    guard !isFetching else { return .empty() }
    isFetching = true
    
    return fetch(nextCursorID)
      .do(onNext: { [weak self] items, nextCursorID, isLast in
        self?.isFetching = false
        self?.isLast = isLast
        self?.nextCursorID = nextCursorID
      })
      .map { $0.content }
  }
}
