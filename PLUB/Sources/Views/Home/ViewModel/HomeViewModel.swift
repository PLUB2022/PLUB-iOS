//
//  HomeViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift
import RxCocoa

protocol HomeViewModelType {
  // Input
  
  // Output
  var fetchedMainCategoryList: Driver<[MainCategory]> { get }
}

class HomeViewModel: HomeViewModelType {
  var disposeBag = DisposeBag()
  
  // Input
  
  // Output
  let fetchedMainCategoryList: Driver<[MainCategory]>
  
  init() {
    let fetchingMainCategoryList = BehaviorSubject<[MainCategory]>(value: [])
    self.fetchedMainCategoryList = fetchingMainCategoryList.asDriver(onErrorDriveWith: .empty())
    
    let inquireMainCategoryList = CategoryService.shared.inquireMainCategoryList().share()
    let successFetchingMainCategoryList = inquireMainCategoryList.map { result -> [MainCategory]? in
      guard case .success(let mainCategoryListResponse) = result else { return nil }
      return mainCategoryListResponse.data?.categories
    }
    
    successFetchingMainCategoryList.subscribe(onNext: { mainCategories in
      guard let mainCategories = mainCategories else { return }
      fetchingMainCategoryList.onNext(mainCategories)
    })
    .disposed(by: disposeBag)
  }
}
