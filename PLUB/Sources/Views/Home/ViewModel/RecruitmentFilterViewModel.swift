//
//  RecruitmentFilterViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/02/24.
//

import RxSwift
import RxCocoa

protocol RecruitmentFilterViewModelType {
  // Input
  var selectCategoryID: AnyObserver<String> { get }
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { get }
}

final class RecruitmentFilterViewModel: RecruitmentFilterViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리 목록
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
    
    selectCategoryID = selectingCategoryID.asObserver()
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    
    let requestSubCategory = selectingCategoryID
      .compactMap { Int($0) }
      .flatMapLatest(CategoryService.shared.inquireSubCategoryList(categoryId: ))
    
    let successRequestSubCategory = requestSubCategory.compactMap { result -> [SubCategory]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.categories
    }
    
    successRequestSubCategory.map { categories in
      return categories.map { category in
        return RecruitmentFilterCollectionViewCellModel(subCategoryID: category.id, name: category.name)
      }
    }
    .subscribe(onNext: selectingSubCategories.accept)
    .disposed(by: disposeBag)
    
    // Output
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    
  }
}
