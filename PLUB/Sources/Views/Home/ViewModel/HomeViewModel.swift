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
  var tappedBookmark: AnyObserver<Int> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var fetchedMainCategoryList: Driver<[MainCategory]> { get }
  var updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var isSelectedInterest: Driver<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class HomeViewModel: HomeViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let tappedBookmark: AnyObserver<Int> // 북마크버튼을 탭 했을때
  let fetchMoreDatas: AnyObserver<Void> // 더 많은 데이터를 받을 것인지
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]> // 메인 카테고리에 대한 데이터
  let updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]> // 추천 모임에 대한 데이터
  let isSelectedInterest: Driver<Bool> // 해당 사용자가 관심사 선택 유무
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  init() {
    let fetchingMainCategoryList = BehaviorRelay<[MainCategory]>(value: [])
    let fetchingRecommendation = BehaviorRelay<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let whichBookmark = PublishSubject<Int>()
    let isSelectingInterest = BehaviorSubject<Bool>(value: false)
    let fetchingDatas = PublishSubject<Void>()
    let currentCursorID = BehaviorRelay<Int>(value: 0)
    let isLastPage = BehaviorSubject<Bool>(value: false)
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    isSelectedInterest = isSelectingInterest.asDriver(onErrorDriveWith: .empty())
    tappedBookmark = whichBookmark.asObserver()
    fetchedMainCategoryList = fetchingMainCategoryList.asDriver(onErrorDriveWith: .empty())
    updatedRecommendationCellData = fetchingRecommendation.asDriver(onErrorDriveWith: .empty())
    fetchMoreDatas = fetchingDatas.asObserver()
    
    let inquireMainCategoryList = CategoryService.shared.inquireMainCategoryList().share()
    let inquireInterest = AccountService.shared.inquireInterest().share()
    
    let successFetchingMainCategoryList = inquireMainCategoryList.compactMap { result -> [MainCategory]? in
      guard case .success(let mainCategoryListResponse) = result else { return nil }
      return mainCategoryListResponse.data?.categories
    }
    
    let successFetchingInterest = inquireInterest.compactMap { result -> InquireInterestResponse? in
      guard case .success(let interestResponse) = result else { return nil }
      return interestResponse.data
    }
    
    let inquireRecommendationMeeting = currentCursorID
      .flatMapLatest { cursorID in
        if try !isLastPage.value() && !isLoading.value() { // 마지막 페이지가 아니고 로딩중이 아닐때
          isLoading.onNext(true)
          return MeetingService.shared.inquireRecommendationMeeting(cursorID: cursorID)
        }
        return .empty()
      }
    
    let successFetchingRecommendationMeeting = inquireRecommendationMeeting.compactMap { result -> [Content]? in
      guard case .success(let recommendationMeetingResponse) = result else { return nil }
      isLastPage.onNext(recommendationMeetingResponse.data?.last ?? false)
      return recommendationMeetingResponse.data?.content
    }
    
    successFetchingInterest.subscribe(onNext: { response in
      isSelectingInterest.onNext(!response.categoryID.isEmpty)
    })
    .disposed(by: disposeBag)
    
    successFetchingRecommendationMeeting.subscribe(onNext: { contents in
      let contents = contents.map { SelectedCategoryCollectionViewCellModel(content: $0) }
      var cellData = fetchingRecommendation.value
      cellData.append(contentsOf: contents)
      fetchingRecommendation.accept(cellData)
      isLoading.onNext(false)
    })
    .disposed(by: disposeBag)
    
    successFetchingMainCategoryList
      .bind(to: fetchingMainCategoryList)
      .disposed(by: disposeBag)
    
    fetchingDatas.withLatestFrom(currentCursorID)
      .filter({ page in
        try isLastPage.value() || isLoading.value() ? false : true
      })
      .map { $0 + 1 }
      .bind(to: currentCursorID)
      .disposed(by: disposeBag)
    
    let requestBookmark = whichBookmark
      .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    self.isBookmarked = successRequestBookmark.distinctUntilChanged()
      .map { $0.isBookmarked }
      .asSignal(onErrorSignalWith: .empty())
  }
}
