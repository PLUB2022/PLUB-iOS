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
  var isSelectSubCategory: AnyObserver<(Bool, Int)> { get }
  var isSelectDay: AnyObserver<(Bool, Day)> { get }
  var confirmAccountNum: AnyObserver<Int> { get }
  var filterConfirm: AnyObserver<Void> { get }
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { get }
  var fetchedDayModel: Signal<[RecruitmentFilterDateCollectionViewCellModel]> { get }
  var isButtonEnabled: Driver<Bool> { get }
  var confirmRequest: Signal<CategoryMeetingRequest> { get }
}

final class RecruitmentFilterViewModel: RecruitmentFilterViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let isSelectSubCategory: AnyObserver<(Bool, Int)> // 세부카테고리 혹은 요일 셀을 선택할때
  let isSelectDay: AnyObserver<(Bool, Day)>
  let filterConfirm: AnyObserver<Void>
  let confirmAccountNum: AnyObserver<Int>
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> // 선택된 서브카테고리 목록
  var fetchedDayModel: Signal<[RecruitmentFilterDateCollectionViewCellModel]>
  let isButtonEnabled: Driver<Bool> // 필터버튼 활성화 여부
  let confirmRequest: Signal<CategoryMeetingRequest>
  
  init(categoryID: Int) {
    let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
    let fetchingDayModel = BehaviorRelay<[RecruitmentFilterDateCollectionViewCellModel]>(value: Day.allCases.map { RecruitmentFilterDateCollectionViewCellModel(day: $0) })
    let isSelectingSubCategory = PublishSubject<(Bool, Int)>()
    let isSelectingDay = PublishSubject<(Bool, Day)>()
    let confirmSubCategory = BehaviorRelay<[Int]>(value: [])
    let confirmDay = BehaviorRelay<[String]>(value: [])
    let filterConfirming = PublishSubject<Void>()
    let confirmingAccountNum = BehaviorSubject<Int>(value: 4)
    
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    isSelectSubCategory = isSelectingSubCategory.asObserver()
    isSelectDay = isSelectingDay.asObserver()
    filterConfirm = filterConfirming.asObserver()
    confirmAccountNum = confirmingAccountNum.asObserver()
    
    
    let requestSubCategory = CategoryService.shared.inquireSubCategoryList(categoryID: categoryID)
    
    let successRequestSubCategory = requestSubCategory.compactMap { result -> [SubCategory]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.categories
    }
    
    successRequestSubCategory.map { subCategories in
      return subCategories.map { RecruitmentFilterCollectionViewCellModel(subCategory: $0) }
    }
    .bind(to: selectingSubCategories)
    .disposed(by: disposeBag)
    
    
    // 서브카테고리를 선택함에 따른 동작
    isSelectingSubCategory
      .subscribe(onNext: { subCategoryInfo in
        let (isSelect, subCategoryID) = subCategoryInfo
        var list = confirmSubCategory.value
        if list.contains(subCategoryID) {
          let filterList = list.filter { $0 != subCategoryID }
          confirmSubCategory.accept(filterList)
        } else {
          list.append(subCategoryID)
          confirmSubCategory.accept(list)
        }
      })
      .disposed(by: disposeBag)
    
    // 요일을 선택함에 따른 동작
    isSelectingDay
      .subscribe(onNext: { selectInfo in
        let (isSelect, day) = selectInfo
        
        var list = confirmDay.value
        let fetchList = fetchingDayModel.value
        if day == .all && isSelect { // 리스트에 해당 요일이 존재하는지 확인하기전에 선택한 요일이 요일무관인지 확인
          confirmDay.accept([])
          fetchingDayModel.accept(Day.allCases.map { day in
            day == .all ? RecruitmentFilterDateCollectionViewCellModel(day: .all, isTapped: true)
                        : RecruitmentFilterDateCollectionViewCellModel(day: day)
          })
        }
        else if list.contains(day.eng) { // 만약에 필터할 요일리스트에 해당 요일이 존재한다면
          let filterList = list.filter { $0 != day.eng }
          let fetchList = fetchList.map { model in
            if model.day == .all {
              return RecruitmentFilterDateCollectionViewCellModel(day: .all)
            } else if model.day == day {
              return RecruitmentFilterDateCollectionViewCellModel(day: day, isTapped: true)
            }
            return model
          }
          
          fetchingDayModel.accept(fetchList)
          confirmDay.accept(filterList)
        }
        else { // 만약에 필터할 요일리스트에 해당 요일이 존재하지않는다면
          let fetchList = fetchList.map { model in
            if model.day == .all {
              return RecruitmentFilterDateCollectionViewCellModel(day: .all)
            } else if model.day == day {
              return RecruitmentFilterDateCollectionViewCellModel(day: day, isTapped: true)
            }
            return model
          }
          
          fetchingDayModel.accept(fetchList)
          list.append(day.eng)
          confirmDay.accept(list)
        }
      })
      .disposed(by: disposeBag)
    
    // Output
    selectedSubCategories = selectingSubCategories.asSignal(onErrorSignalWith: .empty())
    
    isButtonEnabled = Observable.combineLatest(
      selectingSubCategories,
      fetchingDayModel
    )
    { subCategories, days -> Bool in
      return subCategories.filter { $0.isTapped }.count > 0 && days.filter { $0.isTapped }.count > 0
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
    
    fetchedDayModel = fetchingDayModel.asSignal(onErrorSignalWith: .empty())
  }
}
