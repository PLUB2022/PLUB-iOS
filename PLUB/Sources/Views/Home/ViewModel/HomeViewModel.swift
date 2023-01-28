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
}

class HomeViewModel: HomeViewModelType {
  var disposeBag = DisposeBag()
  
  // Input
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]>
  let updatedRecommendationCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  
  init() {
    let fetchingMainCategoryList = BehaviorSubject<[MainCategory]>(value: [])
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
            peopleCount: 0,
            when: ""
          )
        )
        return cellData
      }
    }.asDriver(onErrorDriveWith: .empty())
    
    successFetchingMainCategoryList
      .bind(to: fetchingMainCategoryList)
    .disposed(by: disposeBag)
  }
}
