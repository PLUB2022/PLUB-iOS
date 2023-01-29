//
//  InterestListViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift
import RxCocoa

protocol SelectedCategoryViewModelType {
  // Input
  var selectCategoryID: AnyObserver<String> { get }
  
  // Output
  var updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
}

class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private var disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String>
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let updatingCellData = BehaviorSubject<[SelectedCategoryCollectionViewCellModel]>(value: [])
    self.selectCategoryID = selectingCategoryID.asObserver()
    self.updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    
    let fetchingSelectedCategory = selectingCategoryID.flatMapLatest { categoryId in
      return MeetingService.shared.inquireCategoryMeeting(categoryId: categoryId)
    }
    .share()

    let successFetching = fetchingSelectedCategory.map { result -> CategoryMeetingResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let selectingContents = successFetching.map { response -> [Content]? in
      guard let response = response else { return nil }
      return response.content
    }
    
    selectingContents.subscribe(onNext: { contents in
      guard let contents = contents else { return }
      let model = contents.map { content in
        return SelectedCategoryCollectionViewCellModel(plubbingID: content.plubbingID, name: content.name, title: content.title, mainImage: content.mainImage, introduce: content.introduce, isBookmarked: content.isBookmarked, selectedCategoryInfoModel: .init(placeName: content.placeName, peopleCount: 5, when: "서울 서초구 | 월, 화, 수"))
      }
      updatingCellData.onNext(model)
    })
    .disposed(by: disposeBag)
  }
}
