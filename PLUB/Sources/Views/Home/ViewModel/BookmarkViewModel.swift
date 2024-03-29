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
  var tappedBookmark: AnyObserver<Int> { get }
  
  // Output
  var isBookmarked: Signal<Bool> { get }
  var updatedCellData: Signal<[SelectedCategoryCollectionViewCellModel]> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class BookmarkViewModel: BookmarkViewModelType {
  // Input
  let tappedBookmark: AnyObserver<Int> // 북마크버튼을 탭 했을때
  
  // Output
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  let updatedCellData: Signal<[SelectedCategoryCollectionViewCellModel]> // 해당 ID와 분류타입에 대한 카테고리 데이터
  
  init() {
    let whichBookmark = PublishSubject<Int>()
    
    tappedBookmark = whichBookmark.asObserver()
    
    let requestBookmark = whichBookmark
    .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let inquireBookmarkAll = RecruitmentService.shared.inquireBookmarkAll().share()
    
    let successBookmarkAll = inquireBookmarkAll.compactMap { result -> [CategoryContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    updatedCellData = successBookmarkAll.map { contents in
      return contents.map { SelectedCategoryCollectionViewCellModel(content: $0) }
    }.asSignal(onErrorSignalWith: .empty())
    
    isBookmarked = successRequestBookmark.distinctUntilChanged()
    .map { $0.isBookmarked }
    .asSignal(onErrorSignalWith: .empty())
  }
}
