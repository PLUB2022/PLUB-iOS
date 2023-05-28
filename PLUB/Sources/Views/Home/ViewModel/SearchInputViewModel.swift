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
  var tappedBookmark: AnyObserver<Int> { get }
  var fetchMoreDatas: AnyObserver<Void> { get }
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var currentRecentKeyword: Driver<[String]> { get }
  var keywordListIsEmpty: Driver<Bool> { get }
  var searchOutputIsEmpty: Driver<Bool> { get }
  var isBookmarked: Signal<Bool> { get }
  
  func clearStatus()
}

final class SearchInputViewModel {
  private let disposeBag = DisposeBag()
  
  private let searchKeyword = BehaviorSubject<String>(value: "")
  private let searchSortType = BehaviorSubject<SortType>(value: .popular)
  private let searchFilterType = BehaviorSubject<FilterType>(value: .title)
  private let fetchingSearchOutput = BehaviorRelay<[SelectedCategoryCollectionViewCellModel]>(value: [])
  private let recentKeywordList = BehaviorRelay<[String]>(value: UserManager.shared.recentKeywordList ?? [])
  private let removeKeyword = PublishSubject<Int>()
  private let removeAllKeyword = PublishSubject<Void>()
  private let whichBookmark = PublishSubject<Int>()
  private let fetchingDatas = PublishSubject<Void>()
  private let currentPage = BehaviorRelay<Int>(value: 1)
  private let isLastPage = BehaviorRelay<Bool>(value: false)
  private let isLoading = BehaviorRelay<Bool>(value: false)
  private let lastID = PublishSubject<Int>()
  private let isBookmarking = BehaviorRelay<Bool>(value: false)
  
  init() {
    trySearchRecruitment()
    tryAddKeywordList()
    tryRemoveAllKeywordList()
    tryRemoveOneKeywordList()
    tryBookmarkOrNot()
    tryFetchingData()
  }
  
  func clearStatus() {
    self.fetchingSearchOutput.accept([])
    self.isLastPage.accept(false)
    self.isLoading.accept(false)
    self.currentPage.accept(1)
  }
  
  private func tryRemoveOneKeywordList() {
    // 최근 검색어 목록 관련 로직
    removeKeyword
      .subscribe(with: self) { owner, index in
        var list = owner.recentKeywordList.value
        list.remove(at: index)
        owner.recentKeywordList.accept(list)
        UserManager.shared.removeKeyword(index: index)
      }
      .disposed(by: disposeBag)
  }
  
  private func tryRemoveAllKeywordList() {
    removeAllKeyword
      .subscribe(with: self) { owner, _ in
        UserManager.shared.clearKeywordList()
        owner.recentKeywordList.accept(UserManager.shared.recentKeywordList!)
      }
      .disposed(by: disposeBag)
  }
  
  private func tryAddKeywordList() {
    searchKeyword
      .skip(1)
      .subscribe(with: self) { owner, keyword in
        UserManager.shared.addKeyword(keyword: keyword)
        owner.recentKeywordList.accept(UserManager.shared.recentKeywordList!)
      }
      .disposed(by: disposeBag)
  }
  
  private func tryBookmarkOrNot() {
    // 북마크 요청/취소 로직
    let requestBookmark = whichBookmark
      .flatMapLatest(RecruitmentService.shared.requestBookmark)
      .share()
    
    let successRequestBookmark = requestBookmark.compactMap { result -> RequestBookmarkResponse? in
      guard case .success(let response) = result else { return nil }
      return response.data
    }
    
    successRequestBookmark.distinctUntilChanged()
      .map { $0.isBookmarked }
      .bind(to: isBookmarking)
      .disposed(by: disposeBag)
  }
  
  private func trySearchRecruitment() {
    let searchRecruitment = Observable.combineLatest(
      searchKeyword,
      currentPage,
      searchFilterType,
      searchSortType
    )
      .skip(1)
      .withUnretained(self)
      .flatMapLatest { (owner, result) in
        owner.isLoading.accept(true)
        let (keyword, currentPage, filterType, sortType) = result
        return RecruitmentService.shared.searchRecruitment(
          searchParameter: .init(
            keyword: keyword,
            cursorID: currentPage,
            type: filterType.toEng,
            sort: sortType.toEng
          )
        )
      }
    
    searchRecruitment
      .subscribe(with: self) { owner, response in
        guard let lastPlubbingID = response.content.last?.plubbingID else { return }
        owner.lastID.onNext(lastPlubbingID)
        
        let model = response.content.map { SelectedCategoryCollectionViewCellModel(content: $0) }
        
        var cellData = owner.fetchingSearchOutput.value
        cellData.append(contentsOf: model)
        owner.fetchingSearchOutput.accept(cellData)
        owner.isLoading.accept(false)
        owner.isLastPage.accept(response.isLast)
      }
      .disposed(by: disposeBag)
  }
  
  private func tryFetchingData() {
    fetchingDatas
      .withLatestFrom(lastID)
      .withUnretained(self)
      .filter { owner, _ in !owner.isLastPage.value && !owner.isLoading.value }
      .subscribe(onNext: { owner, lastPlubbingID in
        owner.currentPage.accept(lastPlubbingID)
      })
      .disposed(by: disposeBag)
  }
}

extension SearchInputViewModel: SearchInputViewModelType {
  // Input
  var whichKeyword: AnyObserver<String> {
    searchKeyword.asObserver()
  } // 어떤 키워드로 검색할 것인지
  
  var whichSortType: AnyObserver<SortType> {
    searchSortType.asObserver()
  } // 어떤 분류타입으로 검색할 것인지
  
  var whichFilterType: AnyObserver<FilterType> {
    searchFilterType.asObserver()
  } // 어떤 필터타입으로 검색할 것인지
  
  var whichKeywordRemove: AnyObserver<Int> {
    removeKeyword.asObserver()
  } // 어떤 인덱스에 해당하는 remove버튼을 눌렀는지
  
  var tappedRemoveAll: AnyObserver<Void> {
    removeAllKeyword.asObserver()
  } // 모두 지우기 버튼을 눌렀는지
  
  var tappedBookmark: AnyObserver<Int> {
    whichBookmark.asObserver()
  } // 북마크버튼을 탭 했을때
  
  var fetchMoreDatas: AnyObserver<Void> {
    fetchingDatas.asObserver()
  } // 더 많은 데이터를 받을 것인지
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> {
    fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
  } // 검색결과
  
  var currentRecentKeyword: Driver<[String]> {
    recentKeywordList.asDriver(onErrorDriveWith: .empty())
  } // 최근 검색어 목록
  
  var keywordListIsEmpty: Driver<Bool> {
    recentKeywordList
      .map { $0.isEmpty }
      .asDriver(onErrorJustReturn: true)
  } // 최근 검색어 목록이 비어있는지
  
  var searchOutputIsEmpty: Driver<Bool> {
    fetchingSearchOutput.skip(1)
      .map { $0.isEmpty }
      .asDriver(onErrorJustReturn: true)
  } // 해당 키워드에 대한 검색결과가 존재하는지
  
  var isBookmarked: Signal<Bool> {
    isBookmarking
      .asSignal(onErrorSignalWith: .empty())
  } // [북마크][북마크해제] 성공 유무
}
