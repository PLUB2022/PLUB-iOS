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
  var selectSubCategory: AnyObserver<Int> { get }
  var selectDay: AnyObserver<Day> { get }
  var deselectSubCategory: AnyObserver<Int> { get }
  var deselectDay: AnyObserver<Day> { get }
  var confirmAccountNum: AnyObserver<Int> { get }
  var filterConfirm: AnyObserver<Void> { get }
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { get }
  var isButtonEnabled: Driver<Bool> { get }
  var confirmRequest: Signal<CategoryMeetingRequest> { get }
}

final class RecruitmentFilterViewModel: RecruitmentFilterViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectCategoryID: AnyObserver<String> // 어떤 카테고리에 대한 것인지에 대한 ID
  let selectSubCategory: AnyObserver<Int> // 세부카테고리 혹은 요일 셀을 선택할때
  let selectDay: AnyObserver<Day>
  let deselectSubCategory: AnyObserver<Int> // 세부카테고리 혹은 요일 셀을 선택하지않을때
  let deselectDay: AnyObserver<Day>
  let filterConfirm: AnyObserver<Void>
  let confirmAccountNum: AnyObserver<Int>
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리 목록
  let isButtonEnabled: Driver<Bool> // 필터버튼 활성화 여부
  let confirmRequest: Signal<CategoryMeetingRequest>
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
    let selectingSubCategory = PublishSubject<Int>()
    let selectingDay = PublishSubject<Day>()
    let deselectingSubCategory = PublishSubject<Int>()
    let deselectingDay = PublishSubject<Day>()
    let subCategoryCount = BehaviorRelay<Int>(value: 0)
    let dayCount = BehaviorRelay<Int>(value: 0)
    let confirmSubCategory = BehaviorRelay<[Int]>(value: [])
    let confirmDay = BehaviorRelay<[String]>(value: [])
    let filterConfirming = PublishSubject<Void>()
    let confirmingAccountNum = BehaviorSubject<Int>(value: 4)
     
    selectCategoryID = selectingCategoryID.asObserver()
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    selectSubCategory = selectingSubCategory.asObserver()
    selectDay = selectingDay.asObserver()
    deselectSubCategory = deselectingSubCategory.asObserver()
    deselectDay = deselectingDay.asObserver()
    filterConfirm = filterConfirming.asObserver()
    confirmAccountNum = confirmingAccountNum.asObserver()
    
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
    
    Observable.merge(
      selectingSubCategory.withLatestFrom(subCategoryCount) { ($0, $1) }
        .map { ($0, $1 + 1) },
      deselectingSubCategory.withLatestFrom(subCategoryCount) { ($0, $1) }
        .map { ($0, $1 - 1) }
    )
    .subscribe(onNext: { (categoryID, count) in
      var list = confirmSubCategory.value
      if list.contains(categoryID) {
        let filterList = list.filter { $0 != categoryID }
        confirmSubCategory.accept(filterList)
      } else {
        list.append(categoryID)
        confirmSubCategory.accept(list)
      }
      subCategoryCount.accept(count)
    })
    .disposed(by: disposeBag)
    
    Observable.merge(
      selectingDay.withLatestFrom(dayCount) { ($0, $1) }
        .map { ($0, $1 + 1) },
      deselectingDay.withLatestFrom(dayCount) { ($0, $1) }
        .map { ($0, $1 - 1) }
    )
    .subscribe(onNext: { (day, count) in
      var list = confirmDay.value
      if list.contains(day.eng) {
        let filterList = list.filter { $0 != day.eng }
        confirmDay.accept(filterList)
      } else {
        list.append(day.eng)
        confirmDay.accept(list)
      }
      dayCount.accept(count)
    })
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
    
    confirmRequest = filterConfirming.withLatestFrom(
      Observable.zip(
        confirmDay,
        confirmSubCategory,
        confirmingAccountNum
      )
    )
    .map { days, subCategoryIDs, accountNum in
      return CategoryMeetingRequest(
        days: days,
        subCategoryIDs: subCategoryIDs,
        accountNum: accountNum
      )
    }
    .asSignal(onErrorSignalWith: .empty())
  }
}
