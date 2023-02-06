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
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  let whichSortType: AnyObserver<SortType> // 해당 카테고리에 대한 어떤 분류타입으로 설정하고싶은지
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> // 해당 ID와 분류타입에 대한 카테고리 데이터
  let isEmpty: Signal<Bool> // 해당 ID와 분류타입에 대한 카테고리 데이터 유무
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let updatingCellData = BehaviorSubject<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let dataIsEmpty = PublishSubject<Bool>()
    
    isEmpty = dataIsEmpty.asSignal(onErrorSignalWith: .empty())
    whichSortType = searchSortType.asObserver()
    selectCategoryID = selectingCategoryID.asObserver()
    updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    
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
            dateTime: content.days
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
