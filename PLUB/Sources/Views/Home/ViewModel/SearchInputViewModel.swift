//
//  SearchInputViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import RxSwift
import RxCocoa
import RxRelay

protocol SearchInputViewModelType {
  // Input
  var whichKeyword: AnyObserver<String> { get }
  var whichSortType: AnyObserver<SortType> { get }
  var whichFilterType: AnyObserver<FilterType> { get }
  var whichKeywordRemove: AnyObserver<Int> { get }
  var tappedRemoveAll: AnyObserver<Void> { get }
  var tappedBookmark: AnyObserver<String> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var currentRecentKeyword: Driver<[String]> { get }
  var keywordListIsEmpty: Driver<Bool> { get }
  var searchOutputIsEmpty: Driver<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String> // 어떤 키워드로 검색할 것인지
  let whichSortType: AnyObserver<SortType> // 어떤 분류타입으로 검색할 것인지
  let whichFilterType: AnyObserver<FilterType> // 어떤 필터타입으로 검색할 것인지
  let whichKeywordRemove: AnyObserver<Int> // 어떤 인덱스에 해당하는 remove버튼을 눌렀는지
  let tappedRemoveAll: AnyObserver<Void> // 모두 지우기 버튼을 눌렀는지
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  let fetchMoreDatas: AnyObserver<Void> // 더 많은 데이터를 받을 것인지
  
  // Output
  let fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> // 검색결과
  let currentRecentKeyword: Driver<[String]> // 최근 검색어 목록
  let keywordListIsEmpty: Driver<Bool> // 최근 검색어 목록이 비어있는지
  let searchOutputIsEmpty: Driver<Bool> // 해당 키워드에 대한 검색결과가 존재하는지
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  init() {
    let searchKeyword = BehaviorSubject<String>(value: "")
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let searchFilterType = BehaviorSubject<FilterType>(value: .mix)
    let fetchingSearchOutput = BehaviorRelay<[SelectedCategoryCollectionViewCellModel]>(value: [])
    let recentKeywordList = BehaviorRelay<[String]>(value: [])
    let removeKeyword = PublishSubject<Int>()
    let removeAllKeyword = PublishSubject<Void>()
    let whichBookmark = PublishSubject<String>()
    let fetchingDatas = PublishSubject<Void>()
    let currentPage = BehaviorRelay<Int>(value: 1)
    let isLastPage = BehaviorRelay<Bool>(value: false)
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    whichKeywordRemove = removeKeyword.asObserver()
    whichKeyword = searchKeyword.asObserver()
    whichFilterType = searchFilterType.asObserver()
    whichSortType = searchSortType.asObserver()
    fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    currentRecentKeyword = recentKeywordList.asDriver(onErrorDriveWith: .empty())
    tappedRemoveAll = removeAllKeyword.asObserver()
    tappedBookmark = whichBookmark.asObserver()
    fetchMoreDatas = fetchingDatas.asObserver()
    
    let requestSearch = Observable.combineLatest(searchKeyword, searchFilterType, searchSortType)
      .do(onNext: { _ in
        isLastPage.accept(false)
        currentPage.accept(1)
      })
      .skip(1)
      .flatMapLatest { (keyword, filterType, sortType) in
        if !isLastPage.value && !isLoading.value { // 마지막 페이지가 아니고 로딩중이 아닐때
          isLoading.accept(true)
          print("엥")
          return RecruitmentService.shared.searchRecruitment(searchParameter: .init(keyword: keyword, page: currentPage.value, type: filterType.text, sort: sortType.text))
        }
        print("오잉")
        return .empty()
      }
    
    let successSearch = requestSearch.compactMap { result -> [SearchContent]? in
      print("결과 \(result)")
      guard case .success(let response) = result else { return nil }
      isLastPage.accept(response.data?.last ?? false)
      return response.data?.content
    }
    
    let fetchingSearchOutputModel = successSearch.map { contents in
      contents.map { content in
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
    }
    
    removeKeyword.subscribe(onNext: { index in
      var list = recentKeywordList.value
      list.remove(at: index)
      recentKeywordList.accept(list)
    })
    .disposed(by: disposeBag)
    
    searchKeyword.skip(1).subscribe(onNext: { keyword in
      var list = recentKeywordList.value
      if list.contains(keyword) {
        guard let index = list.firstIndex(of: keyword) else { return }
        list.remove(at: index)
      }
      list.insert(keyword, at: 0)
      recentKeywordList.accept(list)
    })
    .disposed(by: disposeBag)
    
    fetchingSearchOutputModel.subscribe(onNext: { model in
      var cellData = fetchingSearchOutput.value
      cellData.append(contentsOf: model)
      fetchingSearchOutput.accept(cellData)
      isLoading.accept(false)
    })
    .disposed(by: disposeBag)
    
    removeAllKeyword
      .subscribe(onNext: { _ in
        recentKeywordList.accept([])
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
    
    fetchingDatas.withLatestFrom(currentPage)
      .filter({ page in
        isLastPage.value || isLoading.value ? false : true
      })
      .map { $0 + 1 }
      .do(onNext: { currentPage.accept($0) })
        .flatMapLatest { page in
          return RecruitmentService.shared.searchRecruitment(searchParameter: .init(keyword: try searchKeyword.value(), page: currentPage.value, type: try searchFilterType.value().text, sort: try searchSortType.value().text))
        }
    
    //      .subscribe(onNext: { page in
    //        currentPage.accept(page)
    //
    //      })
    //      .disposed(by: disposeBag)
    
    keywordListIsEmpty = recentKeywordList.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
    searchOutputIsEmpty = fetchingSearchOutput.skip(1).map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
  }
}
