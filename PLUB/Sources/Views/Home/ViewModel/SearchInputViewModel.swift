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
  var whichKeywordRemove: AnyObserver<Int> { get }
  var tappedRemoveAll: AnyObserver<Void> { get }
  var tappedBookmark: AnyObserver<String> { get }
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var currentRecentKeyword: Driver<[String]> { get }
  var keywordListIsEmpty: Driver<Bool> { get }
  var searchOutputIsEmpty: Driver<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String> // 어떤 키워드로 검색할 것인지
  let whichSortType: AnyObserver<SortType> // 어떤 분류타입으로 검색할 것인지
  let whichKeywordRemove: AnyObserver<Int> // 어떤 인덱스에 해당하는 remove버튼을 눌렀는지
  let tappedRemoveAll: AnyObserver<Void> // 모두 지우기 버튼을 눌렀는지
  let tappedBookmark: AnyObserver<String> // 북마크버튼을 탭 했을때
  
  // Output
  let fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> // 검색결과
  let currentRecentKeyword: Driver<[String]> // 최근 검색어 목록
  let keywordListIsEmpty: Driver<Bool> // 최근 검색어 목록이 비어있는지
  let searchOutputIsEmpty: Driver<Bool> // 해당 키워드에 대한 검색결과가 존재하는지
  let isBookmarked: Signal<Bool> // [북마크][북마크해제] 성공 유무
  
  
  init() {
    let searchKeyword = PublishSubject<String>()
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let fetchingSearchOutput = PublishSubject<[SelectedCategoryCollectionViewCellModel]>()
    let recentKeywordList = BehaviorRelay<[String]>(value: [])
    let removeKeyword = PublishSubject<Int>()
    let removeAllKeyword = PublishSubject<Void>()
    let whichBookmark = PublishSubject<String>()
    
    whichKeywordRemove = removeKeyword.asObserver()
    whichKeyword = searchKeyword.asObserver()
    whichSortType = searchSortType.asObserver()
    fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    currentRecentKeyword = recentKeywordList.asDriver(onErrorDriveWith: .empty())
    tappedRemoveAll = removeAllKeyword.asObserver()
    tappedBookmark = whichBookmark.asObserver()
    
    let requestSearch = Observable.combineLatest(searchKeyword, searchSortType) { ($0, $1) }
      .flatMapLatest { (keyword, sortType) in
        return RecruitmentService.shared.searchRecruitment(searchParameter: .init(keyword: keyword, sort: sortType.text))
      }
    
    let successSearch = requestSearch.compactMap { result -> [SearchContent]? in
      guard case .success(let response) = result else { return nil }
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
      
    searchKeyword.subscribe(onNext: { keyword in
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
      fetchingSearchOutput.onNext(model)
    })
    .disposed(by: disposeBag)
    
    removeAllKeyword
      .subscribe(onNext: { _ in
        recentKeywordList.accept([])
      })
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
    
    keywordListIsEmpty = recentKeywordList.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
    searchOutputIsEmpty = fetchingSearchOutput.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
  }
}
