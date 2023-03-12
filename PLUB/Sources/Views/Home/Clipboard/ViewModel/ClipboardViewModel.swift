// 
//  ClipboardViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/02/25.
//

import Foundation

import RxSwift
import RxCocoa

protocol ClipboardViewModelType {
  // Input
  
  // Output
  var fetchClipboards: Driver<[FeedsContent]> { get }
}

protocol ClipboardCellDataStore {
  var cellHeights: [Int] { get } // IndexPath별 `ClipboardCollectionViewCell`의 높이
}

final class ClipboardViewModel: ClipboardViewModelType, ClipboardCellDataStore {
  
  // Input
  
  // Output
  let fetchClipboards: Driver<[FeedsContent]>
  private(set) var cellHeights: [Int] = []
  
  
  init(plubIdentifier: Int) {
    fetchClipboards = FeedsService.shared.fetchClipboards(plubIdentifier: plubIdentifier)
      .compactMap { response -> [FeedsContent]? in
        // TODO: 승현 - API failure 처리
        guard case let .success(data) = response else { return nil }
        return data.data?.pinnedFeedList
      }
      .asDriver(onErrorJustReturn: [])
  }
  
  private let disposeBag = DisposeBag()
}
