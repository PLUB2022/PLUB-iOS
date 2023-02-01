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
  var tappedBookmark: AnyObserver<String> { get }
  
  // Output
  var fetchedMainCategoryList: Driver<[MainCategory]> { get }
  var updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var isSelectedInterest: Driver<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

final class HomeViewModel: HomeViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let tappedBookmark: AnyObserver<String>
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]>
  let updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  let isSelectedInterest: Driver<Bool>
  let isBookmarked: Signal<Bool>
  
  init() {
    let fetchingMainCategoryList = BehaviorSubject<[MainCategory]>(value: [])
    let whichBookmark = PublishSubject<String>()
    let isSelectingInterest = BehaviorSubject<Bool>(value: false)
    
    self.isSelectedInterest = isSelectingInterest.asDriver(onErrorDriveWith: .empty())
    self.tappedBookmark = whichBookmark.asObserver()
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
    
    successFetchingInterest.subscribe(onNext: { response in
      isSelectingInterest.onNext(!response.categoryID.isEmpty)
    })
    .disposed(by: disposeBag)
    
    updatedRecommendationCellData = successFetchingRecommendationMeeting.map { contents in
      return contents.map { content in
        let cellData = SelectedCategoryCollectionViewCellModel(
          plubbingID: "\(content.plubbingID)",
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
    
    let requestBookmark = whichBookmark
      .debounce(.seconds(3), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .default))
      .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    self.isBookmarked = successRequestBookmark.distinctUntilChanged()
      .map { $0.isBookmarked }
      .asSignal(onErrorSignalWith: .empty())
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
