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
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { get }
  var isEmpty: Signal<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class SelectedCategoryViewModel: SelectedCategoryViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  let whichSortType: AnyObserver<SortType> // 해당 카테고리에 대한 어떤 분류타입으로 설정하고싶은지
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  let fetchMoreDatas: AnyObserver<Void> // 더 많은 데이터를 받을 것인지
  
  // Output
  let updatedCellData: Driver<[SelectedCategoryCollectionViewCellModel]> // 해당 ID와 분류타입에 대한 카테고리 데이터
  let selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리목록
  let isEmpty: Signal<Bool> // 해당 ID와 분류타입에 대한 카테고리 데이터 유무
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  init() {
    let selectingCategoryID = BehaviorSubject<String>(value: "")
    let updatingCellData = BehaviorRelay<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let dataIsEmpty = PublishSubject<Bool>()
    let whichBookmark = PublishSubject<String>()
    let fetchingDatas = PublishSubject<Void>()
    let currentPage = BehaviorRelay<Int>(value: 1)
    let isLastPage = BehaviorRelay<Bool>(value: false)
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    isEmpty = dataIsEmpty.asSignal(onErrorSignalWith: .empty())
    whichSortType = searchSortType.asObserver()
    selectCategoryID = selectingCategoryID.asObserver()
    updatedCellData = updatingCellData.asDriver(onErrorDriveWith: .empty())
    tappedBookmark = whichBookmark.asObserver()
    fetchMoreDatas = fetchingDatas.asObserver()
    
    let fetchingSelectedCategory = Observable.combineLatest(
      selectingCategoryID,
      searchSortType
    ) { ($0, $1) }
      .skip(1)
      .do(onNext: { _ in
        isLastPage.accept(false)
        currentPage.accept(1)
        updatingCellData.accept([])
      })
      .flatMapLatest { (categoryId, sortType) in
        if !isLastPage.value && !isLoading.value { // 마지막 페이지가 아니고 로딩중이 아닐때
          isLoading.accept(true)
          return MeetingService.shared.inquireCategoryMeeting(
            categoryId: categoryId,
            page: currentPage.value,
            sort: sortType.text
          )
        }
        return .empty()
      }
    
    let fetchMore = fetchingDatas.withLatestFrom(currentPage)
      .filter { _ in !isLastPage.value && !isLoading.value }
      .map { $0 + 1 }
      .do(onNext: { page in
        currentPage.accept(page)
        isLoading.accept(true)
      })
      .flatMapLatest { _ in
        return MeetingService.shared.inquireCategoryMeeting(
          categoryId: try selectingCategoryID.value(),
          page: currentPage.value,
          sort: try searchSortType.value().text
        )
      }
    
    let successFetching = Observable.merge(
      fetchingSelectedCategory,
      fetchMore
    )
      .share()
      .compactMap { result -> CategoryMeetingResponse? in
        guard case .success(let response) = result else { return nil }
        return response.data
      }
    
    let selectingContents = successFetching
      .do(onNext: { isLastPage.accept($0.last) })
      .compactMap { response -> [Content]? in
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
        var cellData = updatingCellData.value
        cellData.append(contentsOf: model)
        updatingCellData.accept(cellData)
        isLoading.accept(false)
      })
      .disposed(by: disposeBag)
    
        let requestSubCategory = selectingCategoryID
        .compactMap { Int($0) }
        .flatMapLatest(CategoryService.shared.inquireSubCategoryList(categoryId: ))
    
    let successRequestSubCategory = requestSubCategory.compactMap { result -> [SubCategory]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.categories
    }
    
    selectedSubCategories = successRequestSubCategory.map { categories in
      return categories.map { category in
        return RecruitmentFilterCollectionViewCellModel(subCategoryID: category.id, name: category.name)
      }
    }
    .asSignal(onErrorSignalWith: .empty())
    
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


