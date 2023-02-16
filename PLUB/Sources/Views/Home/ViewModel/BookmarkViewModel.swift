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
  var updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
}

final class BookmarkViewModel: BookmarkViewModelType {
  // Input
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  
  // Output
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> // 해당 ID와 분류타입에 대한 카테고리 데이터
  
  init() {
    let whichBookmark = PublishSubject<String>()
    
    tappedBookmark = whichBookmark.asObserver()
    
    let requestBookmark = whichBookmark
    .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let inquireBookmarkAll = RecruitmentService.shared.inquireBookmarkAll().share()
    
    let successBookmarkAll = inquireBookmarkAll.compactMap { result -> [BookmarkContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    updatedCellData = successBookmarkAll.map { contents in
      return contents.map { content in
        return SelectedCategoryCollectionViewCellModel(
          plubbingID: "\(content.plubbingID)",
          name: content.name,
          title: content.title,
          mainImage: content.mainImage,
          introduce: content.introduce,
          isBookmarked: content.isBookmarked,
          selectedCategoryInfoModel: .init(
            placeName: content.placeName,
            peopleCount: content.remainAccountNum,
            dateTime: content.days
          .map { $0.fromENGToKOR() }
          .joined(separator: ",")
        + " | "
        + "(data.time)"))

      }
    }.asDriver(onErrorDriveWith: .empty())
    
    isBookmarked = successRequestBookmark.distinctUntilChanged()
    .map { $0.isBookmarked }
    .asSignal(onErrorSignalWith: .empty())
  }
}