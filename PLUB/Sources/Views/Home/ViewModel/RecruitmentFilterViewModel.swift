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
  var selectSubCategory: AnyObserver<Void> { get }
  var selectDay: AnyObserver<Void> { get }
  var deselectSubCategory: AnyObserver<Void> { get }
  var deselectDay: AnyObserver<Void> { get }
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { get }
  var isButtonEnabled: Driver<Bool> { get }
}

final class RecruitmentFilterViewModel: RecruitmentFilterViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  let selectSubCategory: AnyObserver<Void> // 세부카테고리 혹은 요일 셀을 선택할때
  let selectDay: AnyObserver<Void>
  let deselectSubCategory: AnyObserver<Void> // 세부카테고리 혹은 요일 셀을 선택하지않을때
  let deselectDay: AnyObserver<Void>
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리 목록
  var isButtonEnabled: Driver<Bool> // 필터버튼 활성화 여부
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
    let selectingSubCategory = PublishSubject<Void>()
    let selectingDay = PublishSubject<Void>()
    let deselectingSubCategory = PublishSubject<Void>()
    let deselectingDay = PublishSubject<Void>()
    let subCategoryCount = BehaviorRelay<Int>(value: 0)
    let dayCount = BehaviorRelay<Int>(value: 0)
    
    selectCategoryID = selectingCategoryID.asObserver()
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    selectSubCategory = selectingSubCategory.asObserver()
    selectDay = selectingDay.asObserver()
    deselectSubCategory = deselectingSubCategory.asObserver()
    deselectDay = deselectingDay.asObserver()
    
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
    
    selectingSubCategory.withLatestFrom(subCategoryCount)
      .map { $0 + 1 }
      .bind(to: subCategoryCount)
      .disposed(by: disposeBag)
    
    selectingDay.withLatestFrom(dayCount)
      .map { $0 + 1 }
      .bind(to: dayCount)
      .disposed(by: disposeBag)
    
    deselectingSubCategory.withLatestFrom(subCategoryCount)
      .map { $0 - 1 }
      .bind(to: subCategoryCount)
      .disposed(by: disposeBag)
    
    deselectingDay.withLatestFrom(dayCount)
      .map { $0 - 1 }
      .bind(to: dayCount)
      .disposed(by: disposeBag)
    
    // Output
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    
    isButtonEnabled = Observable.combineLatest(
      subCategoryCount,
      dayCount
    )
    { subCategoryCnt, dayCnt -> Bool in
      return subCategoryCnt != 0 && dayCnt != 0
    }
    .asDriver(onErrorDriveWith: .empty())
    
  }
}
