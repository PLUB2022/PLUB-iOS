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
  var tappedBookmark: AnyObserver<String> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var isEmpty: Signal<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

final class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  let whichSortType: AnyObserver<SortType> // 해당 카테고리에 대한 어떤 분류타입으로 설정하고싶은지
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  let fetchMoreDatas: AnyObserver<Void> // 더 많은 데이터를 받을 것인지
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> // 해당 ID와 분류타입에 대한 카테고리 데이터
  let isEmpty: Signal<Bool> // 해당 ID와 분류타입에 대한 카테고리 데이터 유무
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let updatingCellData = BehaviorRelay<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let dataIsEmpty = PublishSubject<Bool>()
    let whichBookmark = PublishSubject<String>()
    let fetchingDatas = PublishSubject<Void>()
    let currentPage = BehaviorSubject<Int>(value: 1)
    let isLastPage = BehaviorSubject<Bool>(value: false)
    let isLoading = BehaviorSubject<Bool>(value: false)
    
    isEmpty = dataIsEmpty.asSignal(onErrorSignalWith: .empty())
    whichSortType = searchSortType.asObserver()
    selectCategoryID = selectingCategoryID.asObserver()
    updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    tappedBookmark = whichBookmark.asObserver()
    fetchMoreDatas = fetchingDatas.asObserver()
    
    let fetchingSelectedCategory = Observable.combineLatest(
      selectingCategoryID,
      currentPage.distinctUntilChanged(),
      searchSortType.distinctUntilChanged()
    ) { ($0, $1, $2) }
      .do(onNext: { _ in isLastPage.onNext(false) })
      .flatMapLatest { (categoryId, page, sortType) in
        if try !isLastPage.value() && !isLoading.value() { // 마지막 페이지가 아니고 로딩중이 아닐때
          isLoading.onNext(true)
          return MeetingService.shared.inquireCategoryMeeting(categoryId: categoryId, page: page, sort: sortType.text)
        }
        return .empty()
      }
      .share()
    
    let successFetching = fetchingSelectedCategory.compactMap { result -> CategoryMeetingResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    let selectingContents = successFetching
      .do(onNext: { isLastPage.onNext($0.last) })
      .compactMap { response -> [Content]? in
        return response.content
      }
    
    fetchingDatas.withLatestFrom(currentPage)
      .filter({ page in
        try isLastPage.value() || isLoading.value() ? false : true
      })
      .map { $0 + 1 }
      .bind(to: currentPage)
      .disposed(by: disposeBag)
    
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
        var cellData = updatingCellData.value
        cellData.append(contentsOf: model)
        updatingCellData.accept(cellData)
        isLoading.onNext(false)
      })
      .disposed(by: disposeBag)
        
        let requestBookmark = whichBookmark
        .flatMapLatest(RecruitmentService.shared.requestBookmark).share()
        
        let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
          guard case .success(let response) = result else { return nil }
          return response.data
        }
        
        isBookmarked = successRequestBookmark.distinctUntilChanged()
        .map { $0.isBookmarked }
        .asSignal(onErrorSignalWith: .empty())
  }
}


