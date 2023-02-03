//
//  SearchInputViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/28.
//

import RxSwift
import RxCocoa

protocol SearchInputViewModelType {
  // Input
  var whichKeyword: AnyObserver<String> { get }
  var whichSortType: AnyObserver<SortType> { get }
  
  // Output
  var fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]> { get }
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String>
  let whichSortType: AnyObserver<SortType>
  
  // Output
  let fetchedSearchOutput: Driver<[SelectedCategoryCollectionViewCellModel]>
  
  init() {
    let searchKeyword = PublishSubject<String>()
    let searchSortType = BehaviorSubject<SortType>(value: .popular)
    let fetchingSearchOutput = PublishSubject<[SelectedCategoryCollectionViewCellModel]>()
    
    self.whichKeyword = searchKeyword.asObserver()
    self.whichSortType = searchSortType.asObserver()
    self.fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    
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
      
    fetchingSearchOutputModel.subscribe(onNext: { model in
      fetchingSearchOutput.onNext(model)
    })
    .disposed(by: disposeBag)
  }
}
