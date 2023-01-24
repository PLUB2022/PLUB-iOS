//
//  InterestViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/23.
//

import RxSwift
import RxCocoa

final class InterestViewModel {
  
  // Input
  let selectSubCategory: AnyObserver<Int>   // 선택된 카테고리의 id
  let deselectSubCategory: AnyObserver<Int> // 취소한 카테고리의 id
  
  // Output
  let fetchData: Driver<[RegisterInterestModel]>  // tableView data fetch
  let selectedSubCategories: Driver<[Int]>        // 선택된 카테고리의 id 배열
  let isButtonEnabled: Driver<Bool>               // 버튼 활성화 여부
  
  /// fetch한 카테고리 데이터
  private let fetchedCategoriesSubject = BehaviorSubject<[RegisterInterestModel]>(value: [])
  
  /// 선택된 카테고리의 `Subject`
  private let selectSubject = PublishSubject<Int>()
  
  /// 취소된 카테고리의 `Subject`
  private let deselectSubject = PublishSubject<Int>()
  
  /// 선택된 카테고리의 `Relay`
  private let selectedSubCategoriesRelay = BehaviorRelay<[Int]>(value: [])
  
  private let disposeBag = DisposeBag()
  
  init() {
    fetchData = fetchedCategoriesSubject.asDriver(onErrorDriveWith: .empty())
    selectSubCategory = selectSubject.asObserver()
    deselectSubCategory = deselectSubject.asObserver()
    // emit array of categories when selected categories
    selectedSubCategories = selectedSubCategoriesRelay.asDriver()
    isButtonEnabled = selectedSubCategoriesRelay
      .map { $0.count != 0 }
      .asDriver(onErrorJustReturn: false)
    
    bind()
  }
  
  private func bind() {
    // fetch categories
    CategoryService.shared.inquireAll()
      .compactMap { result -> [Category]? in
        // 필요한 데이터를 가져오고 그 외는 nil 처리
        guard case let .success(allCategoryResponse) = result else { return nil }
        return allCategoryResponse.data?.categories
      }
      .map { return $0.map { RegisterInterestModel(category: $0) } }
      .bind(to: fetchedCategoriesSubject)
      .disposed(by: disposeBag)
    
    // insert subcategory's id in `selectedSubCategoriesRelay`
    selectSubject
      .withUnretained(self)
      .filter { $0.selectedSubCategoriesRelay.value.contains($1) == false }
      .map { owner, value in
        var array = owner.selectedSubCategoriesRelay.value
        array.append(value)
        return array
      }
      .bind(to: selectedSubCategoriesRelay)
      .disposed(by: disposeBag)
    
    // delete subcategory's id in `selectedSubCategoriesRelay`
    deselectSubject
      .withUnretained(self)
      .filter { $0.selectedSubCategoriesRelay.value.contains($1) }
      .map { owner, value in owner.selectedSubCategoriesRelay.value.filter { $0 != value } }
      .bind(to: selectedSubCategoriesRelay)
      .disposed(by: disposeBag)
  }
}
