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
}

class HomeViewModel: HomeViewModelType {
  var disposeBag = DisposeBag()
  
  // Input
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]>
  
  init() {
    let fetchingMainCategoryList = BehaviorSubject<[MainCategory]>(value: [])
    self.fetchedMainCategoryList = fetchingMainCategoryList.asDriver(onErrorDriveWith: .empty())
    
    let inquireMainCategoryList = CategoryService.shared.inquireMainCategoryList().share()
    let inquireRecommendationMeeting = MeetingService.shared.inquireRecommendationMeeting()
    
    let successFetchingMainCategoryList = inquireMainCategoryList.compactMap { result -> [MainCategory]? in
      guard case .success(let mainCategoryListResponse) = result else { return nil }
      return mainCategoryListResponse.data?.categories
    }
    
    let successFetchingRecommendationMeeting = inquireRecommendationMeeting.compactMap { result -> [Content]? in
      guard case .success(let recommendationMeetingResponse) = result else { return nil }
      return recommendationMeetingResponse.data?.content
    }
    
    successFetchingMainCategoryList
      .bind(to: fetchingMainCategoryList)
    .disposed(by: disposeBag)
  }
}
