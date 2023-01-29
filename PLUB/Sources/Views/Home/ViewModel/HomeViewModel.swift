//
//  HomeViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift
import RxCocoa

protocol HomeViewModelType {
  // Input
  
  // Output
  var fetchedMainCategoryList: Driver<[MainCategory]> { get }
  var updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var isSelectedInterest: Signal<Bool> { get }
}

class HomeViewModel: HomeViewModelType {
  var disposeBag = DisposeBag()
  
  // Input
  let addBookmark: AnyObserver<Void>
  let removeBookmark: AnyObserver<Void>
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]>
  let updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  let isSelectedInterest: Signal<Bool>
  
  init() {
    let fetchingMainCategoryList = BehaviorSubject<[MainCategory]>(value: [])
    let requestAddBookmark = PublishSubject<Void>()
    let requestRemoveBookmark = PublishSubject<Void>()
    
    self.addBookmark = requestAddBookmark.asObserver()
    self.removeBookmark = requestRemoveBookmark.asObserver()
    self.fetchedMainCategoryList = fetchingMainCategoryList.asDriver(onErrorDriveWith: .empty())
    
    let inquireMainCategoryList = CategoryService.shared.inquireMainCategoryList().share()
    let inquireRecommendationMeeting = MeetingService.shared.inquireRecommendationMeeting().share()
    let inquireInterest = AccountService.shared.inquireInterest().share()
    
    let successFetchingMainCategoryList = inquireMainCategoryList.compactMap { result -> [MainCategory]? in
      guard case .success(let mainCategoryListResponse) = result else { return nil }
      return mainCategoryListResponse.data?.categories
    }
    
    let successFetchingInterest = inquireInterest.compactMap { result -> InquireInterestResponse? in
      guard case .success(let interestResponse) = result else { return nil }
      return interestResponse.data
    }
    
    let successFetchingRecommendationMeeting = inquireRecommendationMeeting.compactMap { result -> [Content]? in
      guard case .success(let recommendationMeetingResponse) = result else { return nil }
      return recommendationMeetingResponse.data?.content
    }
    
    isSelectedInterest = successFetchingInterest.map { response in
      return !response.categoryID.isEmpty
    }
    .asSignal(onErrorSignalWith: .empty())
    
    updatedRecommendationCellData = successFetchingRecommendationMeeting.map { contents in
      return contents.map { content in
        let cellData = SelectedCategoryCollectionViewCellModel(
          plubbingId: content.plubbingId,
          name: content.name,
          title: content.title,
          mainImage: content.mainImage,
          introduce: content.introduce,
          isBookmarked: content.isBookmarked,
          selectedCategoryInfoModel: .init(
            placeName: content.placeName,
            peopleCount: content.remainAccountNum,
            when: HomeViewModel.formatDays(days: content.days)
          )
        )
        return cellData
      }
    }.asDriver(onErrorDriveWith: .empty())
    
    successFetchingMainCategoryList
      .bind(to: fetchingMainCategoryList)
      .disposed(by: disposeBag)
    
//    requestAddBookmark.withLatestFrom(<#T##second: ObservableConvertibleType##ObservableConvertibleType#>)
  }
  
  private static func formatDays(days: [String]) -> String {
    var formatStr = ""
    days.forEach { day in
      formatStr.append(day.fromENGToKOR() + ",")
    }
    formatStr.removeLast()
    return formatStr
  }
}
