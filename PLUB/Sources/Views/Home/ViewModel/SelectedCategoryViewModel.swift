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
  var whichSortType: AnyObserver<SortType> { get }
  
  // Output
  var updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var isEmpty: Signal<Bool> { get }
}

final class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String>
  let whichSortType: AnyObserver<SortType>
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]>
  let isEmpty: Signal<Bool>
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let updatingCellData = BehaviorSubject<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let dataIsEmpty = PublishSubject<Bool>()
    
    self.isEmpty = dataIsEmpty.asSignal(onErrorSignalWith: .empty())
    self.whichSortType = searchSortType.asObserver()
    self.selectCategoryID = selectingCategoryID.asObserver()
    self.updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    
    let fetchingSelectedCategory = Observable.combineLatest(
      selectingCategoryID,
      searchSortType.distinctUntilChanged()
    ) { ($0, $1) }
      .flatMapLatest { (categoryId, sortType) in
        return MeetingService.shared.inquireCategoryMeeting(categoryId: categoryId, sort: sortType.text)
      }
      .share()
    
    let successFetching = fetchingSelectedCategory.compactMap { result -> CategoryMeetingResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let selectingContents = successFetching.compactMap { response -> [Content]? in
      return response.content
    }
    
    selectingContents
      .do(onNext: { dataIsEmpty.onNext($0.isEmpty) })
      .subscribe(onNext: { contents in
      let model = contents.map { content in
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
            when: content.days
          .map { $0.fromENGToKOR() }
          .joined(separator: ",")
        + " | "
        + "(data.time)"))
      }
      updatingCellData.onNext(model)
    })
    .disposed(by: disposeBag)
  }
  
}
