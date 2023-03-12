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

final class ClipboardViewModel: ClipboardViewModelType {
  
  // Input
  
  // Output
  let fetchClipboards: Driver<[FeedsContent]>
  
  
  
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
