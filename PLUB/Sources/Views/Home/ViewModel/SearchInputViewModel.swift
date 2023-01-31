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
  
  // Output
  var fetchedSearchOutput: Driver<[SearchContent]> { get }
}

final class SearchInputViewModel: SearchInputViewModelType {
  private let disposeBag = DisposeBag()
  
  // Input
  let whichKeyword: AnyObserver<String>
  
  // Output
  let fetchedSearchOutput: Driver<[SearchContent]>
  
  init() {
    let searchKeyword = PublishSubject<String>()
    let fetchingSearchOutput = PublishSubject<[SearchContent]>()
    
    self.whichKeyword = searchKeyword.asObserver()
    self.fetchedSearchOutput = fetchingSearchOutput.asDriver(onErrorDriveWith: .empty())
    
    let requestSearch = searchKeyword
      .flatMapLatest { keyword in
        return RecruitmentService.shared.searchRecruitment(searchParameter: .init(keyword: keyword))
      }
    
    let successSearch = requestSearch.compactMap { result -> [SearchContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
      
    successSearch.subscribe(onNext: { content in
      fetchingSearchOutput.onNext(content)
    })
    .disposed(by: disposeBag)
  }
}
