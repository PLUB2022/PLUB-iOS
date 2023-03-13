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
  
  
  init(plubbingID: Int) {
    // API 여러번 호출 방지
    let sharedClipboardsAPI = FeedsService.shared.fetchClipboards(plubbingID: plubbingID)
      .compactMap { response -> [FeedsContent]? in
        // TODO: 승현 - API failure 처리
        guard case let .success(data) = response else { return nil }
        return data.data?.pinnedFeedList
      }
      .share()
    
    fetchClipboards = sharedClipboardsAPI.asDriver(onErrorJustReturn: [])
    
    sharedClipboardsAPI
      .compactMap {
        // 높이 305 고정 (photo)
        // 높이 114 고정 (photoAndText, text)
        $0.map { $0.type == .photo ? 305 : 114 }
      }
      .subscribe(onNext: { [weak self] in
        self?.cellHeights = $0
      })
      .disposed(by: disposeBag)
  }
  
  private let disposeBag = DisposeBag()
}
