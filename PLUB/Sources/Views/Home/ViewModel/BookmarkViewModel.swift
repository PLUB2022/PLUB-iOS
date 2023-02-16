//
//  BookmarkViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/16.
//

import RxSwift
import RxCocoa

protocol BookmarkViewModelType {
  // Input
  var tappedBookmark: AnyObserver<String> { get }
  
  // Output
  var isBookmarked: Signal<Bool> { get }
}

final class BookmarkViewModel: BookmarkViewModelType {
  // Input
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  
  // Output
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  init() {
    let whichBookmark = PublishSubject<String>()
    
    tappedBookmark = whichBookmark.asObserver()
    
    let requestBookmark = whichBookmark
    .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    isBookmarked = successRequestBookmark.distinctUntilChanged()
    .map { $0.isBookmarked }
    .asSignal(onErrorSignalWith: .empty())
  }
}
