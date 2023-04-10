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
  var isSelectSubCategory: AnyObserver<(Bool, Int)> { get }
  var isSelectDay: AnyObserver<(Bool, Day)> { get }
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
  let isSelectSubCategory: AnyObserver<(Bool, Int)> // 세부카테고리 혹은 요일 셀을 선택할때
  let isSelectDay: AnyObserver<(Bool, Day)>
  let filterConfirm: AnyObserver<Void>
  let confirmAccountNum: AnyObserver<Int>
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리 목록
  let isButtonEnabled: Driver<Bool> // 필터버튼 활성화 여부
  let confirmRequest: Signal<CategoryMeetingRequest>
  
  init() {
    let selectingCategoryID = PublishSubject<String>()
    let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
    let isSelectingSubCategory = PublishSubject<(Bool, Int)>()
    let isSelectingDay = PublishSubject<(Bool, Day)>()
    let subCategoryCount = BehaviorRelay<Int>(value: 0)
    let dayCount = BehaviorRelay<Int>(value: 0)
    let confirmSubCategory = BehaviorRelay<[Int]>(value: [])
    let confirmDay = BehaviorRelay<[String]>(value: [])
    let filterConfirming = PublishSubject<Void>()
    let confirmingAccountNum = BehaviorSubject<Int>(value: 4)
    
    selectCategoryID = selectingCategoryID.asObserver()
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    isSelectSubCategory = isSelectingSubCategory.asObserver()
    isSelectDay = isSelectingDay.asObserver()
    filterConfirm = filterConfirming.asObserver()
    confirmAccountNum = confirmingAccountNum.asObserver()
    
    let requestSubCategory = selectingCategoryID
      .compactMap { Int($0) }
      .flatMapLatest(CategoryService.shared.inquireSubCategoryList(categoryId: ))
    
    let successRequestSubCategory = requestSubCategory.compactMap { result -> [SubCategory]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.categories
    }
    
    successRequestSubCategory.map { subCategories in
      return subCategories.map { RecruitmentFilterCollectionViewCellModel(subCategory: $0) }
    }
    .subscribe(onNext: selectingSubCategories.accept)
    .disposed(by: disposeBag)
    
    
    // 서브카테고리를 선택함에 따른 동작
    isSelectingSubCategory.withLatestFrom(subCategoryCount) { ($0, $1) }
      .subscribe(onNext: { (subCategoryInfo, count) in
        let (isSelect, subCategoryID) = subCategoryInfo
        var list = confirmSubCategory.value
        if list.contains(subCategoryID) {
          let filterList = list.filter { $0 != subCategoryID }
          confirmSubCategory.accept(filterList)
        } else {
          list.append(subCategoryID)
          confirmSubCategory.accept(list)
        }
        isSelect ? subCategoryCount.accept(count + 1) : subCategoryCount.accept(count - 1)
      })
      .disposed(by: disposeBag)
    
    // 요일을 선택함에 따른 동작
    isSelectingDay.withLatestFrom(dayCount) { ($0, $1) }
      .subscribe(onNext: { (selectInfo, count) in
        let (isSelect, day) = selectInfo
        
        var list = confirmDay.value
        if list.contains(day.eng) {
          let filterList = list.filter { $0 != day.eng }
          confirmDay.accept(filterList)
        } else {
          list.append(day.eng)
          confirmDay.accept(list)
        }
        isSelect ? dayCount.accept(count + 1) : dayCount.accept(count - 1)
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
    .map { CategoryMeetingRequest(days: $0, subCategoryIDs: $1, accountNum: $2) }
    .asSignal(onErrorSignalWith: .empty())
  }
}
