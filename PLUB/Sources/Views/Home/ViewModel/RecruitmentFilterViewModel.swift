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
    let confirmDay = BehaviorRelay<[Day]>(value: [])
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
    .subscribe(onNext: { subCategories in
      var subCategories = subCategories
      subCategories.insert(RecruitmentFilterCollectionViewCellModel(
        subCategoryID: Constants.entireID,
        name: Constants.entireName,
        isTapped: false
      ), at: 0)
      selectingSubCategories.accept(subCategories)
    })
    .disposed(by: disposeBag)
    
    // 서브카테고리를 선택함에 따른 동작
    isSelectingSubCategory
      .subscribe(onNext: { subCategoryInfo in
        let (isSelect, subCategoryID) = subCategoryInfo
        var confirmList = confirmSubCategory.value
        let fetchList = selectingSubCategories.value
        
        if subCategoryID == Constants.entireID { // [전체] 카테고리를 선택/미선택 했을 때
          if isSelect {
            let fetchList = fetchList.map { model in
              model.subCategoryID == Constants.entireID ? RecruitmentFilterCollectionViewCellModel(subCategoryID: Constants.entireID, name: Constants.entireName, isTapped: true) : RecruitmentFilterCollectionViewCellModel(model: model, isTapped: false)
            }
            selectingSubCategories.accept(fetchList)
            confirmSubCategory.accept([])
          }
          else {
            let fetchList = fetchList.map { model in
              var model = model
              if model.subCategoryID == Constants.entireID {
                model.isTapped.toggle()
              }
              return model
            }
            selectingSubCategories.accept(fetchList)
          }
        }
        else { // 특정 서브카테고리를 선택/미선택 했을 때
          if isSelect {
            let fetchList = fetchList.map { model in
              if model.subCategoryID == subCategoryID {
                return RecruitmentFilterCollectionViewCellModel(model: model, isTapped: true)
              }
              else if model.subCategoryID == Constants.entireID {
                return RecruitmentFilterCollectionViewCellModel(model: model, isTapped: false)
              }
              return model
            }
            selectingSubCategories.accept(fetchList)
            confirmList.append(subCategoryID)
            confirmSubCategory.accept(confirmList)
          }
          else {
            let fetchList = fetchList.map { model in
              if model.subCategoryID == subCategoryID {
                return RecruitmentFilterCollectionViewCellModel(model: model, isTapped: false)
              }
              return model
            }
            selectingSubCategories.accept(fetchList)
            let confirmList = confirmList.filter { $0 != subCategoryID }
            confirmSubCategory.accept(confirmList)
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 요일을 선택함에 따른 동작
    isSelectingDay
      .subscribe(onNext: { selectInfo in
        let (isSelect, day) = selectInfo
        
        var confirmList = confirmDay.value
        let fetchList = fetchingDayModel.value
        
        if day == .all { // [요일무관] 요일을 선택/미선택 했을 때
          if isSelect {
            let fetchList = fetchList.map { model in
              model.day == .all ? RecruitmentFilterDateCollectionViewCellModel(day: .all, isTapped: true) : RecruitmentFilterDateCollectionViewCellModel(day: model.day)
            }
            fetchingDayModel.accept(fetchList)
            confirmDay.accept([])
          }
          else {
            let fetchList = fetchList.map { model in
              var model = model
              if model.day == .all {
                model.isTapped.toggle()
              }
              return model
            }
            fetchingDayModel.accept(fetchList)
          }
        }
        else { // 특정 요일을 선택/미선택 했을 때
          if isSelect {
            let fetchList = fetchList.map { model in
              if model.day == day {
                return RecruitmentFilterDateCollectionViewCellModel(day: model.day, isTapped: true)
              }
              else if model.day == .all {
                return RecruitmentFilterDateCollectionViewCellModel(day: model.day)
              }
              return model
            }
            fetchingDayModel.accept(fetchList)
            confirmList.append(day)
            confirmDay.accept(confirmList)
          }
          else {
            let fetchList = fetchList.map { model in
              if model.day == day {
                return RecruitmentFilterDateCollectionViewCellModel(day: day)
              }
              return model
            }
            fetchingDayModel.accept(fetchList)
            let confirmList = confirmList.filter { $0 != day }
            confirmDay.accept(confirmList)
          }
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
      return subCategories.filter(\.isTapped).count > 0 && days.filter(\.isTapped).count > 0
    }
    .asDriver(onErrorDriveWith: .empty())
    
    confirmRequest = filterConfirming.withLatestFrom(
      Observable.combineLatest(
        confirmDay,
        confirmSubCategory,
        confirmingAccountNum
      )
    )
    .map { CategoryMeetingRequest(
      days: $0.isEmpty ? nil : $0,
      subCategoryIDs: $1.isEmpty ? nil : $1,
      accountNum: $2
    )
    }
    .asSignal(onErrorSignalWith: .empty())
    
    fetchedDayModel = fetchingDayModel.asSignal(onErrorSignalWith: .empty())
  }
}

extension RecruitmentFilterViewModel {
  struct Constants {
    static let entireID = 0
    static let entireName = "제목"
  }
}
