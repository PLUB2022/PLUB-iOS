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
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var currentRecentKeyword: Driver<[String]> { get }
  var keywordListIsEmpty: Driver<Bool> { get }
  var searchOutputIsEmpty: Driver<Bool> { get }
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String>
  let whichSortType: AnyObserver<SortType>
  let whichKeywordRemove: AnyObserver<Int>
  let tappedRemoveAll: AnyObserver<Void>
  
  // Output
  let fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]>
  let currentRecentKeyword: Driver<[String]>
  let keywordListIsEmpty: Driver<Bool>
  let searchOutputIsEmpty: Driver<Bool>
  
  
  init() {
    let searchKeyword = PublishSubject<String>()
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let fetchingSearchOutput = PublishSubject<[SelectedCategoryCollectionViewCellModel]>()
    let recentKeywordList = BehaviorRelay<[String]>(value: [])
    let removeKeyword = PublishSubject<Int>()
    let removeAllKeyword = PublishSubject<Void>()
    
    self.whichKeywordRemove = removeKeyword.asObserver()
    self.whichKeyword = searchKeyword.asObserver()
    self.whichSortType = searchSortType.asObserver()
    self.fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    self.currentRecentKeyword = recentKeywordList.asDriver(onErrorDriveWith: .empty())
    self.tappedRemoveAll = removeAllKeyword.asObserver()
    
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
            when: content.days
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
    
    keywordListIsEmpty = recentKeywordList.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
    searchOutputIsEmpty = fetchingSearchOutputModel.map { $0.isEmpty }.asDriver(onErrorJustReturn: true)
  }
}
