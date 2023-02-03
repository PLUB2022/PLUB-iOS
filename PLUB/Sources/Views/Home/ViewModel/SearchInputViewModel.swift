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
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
  var currentRecentKeyword: Driver<[String]> { get }
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String>
  let whichSortType: AnyObserver<SortType>
  
  // Output
  let fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]>
  let currentRecentKeyword: Driver<[String]>
  
  init() {
    let searchKeyword = PublishSubject<String>()
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let fetchingSearchOutput = PublishSubject<[SelectedCategoryCollectionViewCellModel]>()
    let recentKeywordList = BehaviorRelay<[String]>(value: [])
    
    self.whichKeyword = searchKeyword.asObserver()
    self.whichSortType = searchSortType.asObserver()
    self.fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    self.currentRecentKeyword = recentKeywordList.asDriver(onErrorDriveWith: .empty())
    
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
      
    searchKeyword.subscribe(onNext: { keyword in
      print("키워드 = \(keyword)")
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
  }
}
