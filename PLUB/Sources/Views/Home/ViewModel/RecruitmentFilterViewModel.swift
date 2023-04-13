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
  let isSelectSubCategory: AnyObserver<(Bool, Int)> // 세부카테고리 선택/미선택
  let isSelectDay: AnyObserver<(Bool, Day)> // 요일 선택/미선택
  let filterConfirm: AnyObserver<Void> // 필터클릭
  let confirmAccountNum: AnyObserver<Int> // 필터하고자하는 인원 수
  
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
        var fetchList = selectingSubCategories.value
        
        // 선택한 서브카테고리를 선택/미선택 기본동작
        let index = fetchList.firstIndex(where: { $0.subCategoryID == subCategoryID })!
        fetchList[index].isTapped = isSelect
        
        if subCategoryID == Constants.entireID { // [전체] 카테고리를 선택/미선택 했을 때, 나머지 카테고리 초기화
          let fetchList = fetchList.map { model in
            if model.subCategoryID != Constants.entireID {
              return RecruitmentFilterCollectionViewCellModel(model: model, isTapped: false)
            }
            return model
          }
          selectingSubCategories.accept(fetchList)
          confirmSubCategory.accept([])
        }
        else { // 특정 서브카테고리를 선택/미선택 했을 때, [전체] 카테고리 미선택
          let fetchList = fetchList.map { model in
            if model.subCategoryID == Constants.entireID {
              return RecruitmentFilterCollectionViewCellModel(model: model, isTapped: false)
            }
            return model
          }
          selectingSubCategories.accept(fetchList)
          confirmList.append(subCategoryID)
          confirmSubCategory.accept(confirmList)
        }
      })
      .disposed(by: disposeBag)
    
    // 요일을 선택함에 따른 동작
    isSelectingDay
      .subscribe(onNext: { selectInfo in
        let (isSelect, day) = selectInfo
        
        var confirmList = confirmDay.value
        var fetchList = fetchingDayModel.value
        
        // 선택한 요일 선택/미선택 기본동작
        let index = fetchList.firstIndex(where: { $0.day == day })!
        fetchList[index].isTapped = isSelect
        
        if day == .all { // [요일무관] 선택/미선택 했을 때, 나머키 요일 초기화
          let fetchList = fetchList.map { model in
            if model.day != .all {
              return RecruitmentFilterDateCollectionViewCellModel(day: model.day)
            }
            return model
          }
          fetchingDayModel.accept(fetchList)
          confirmDay.accept([])
        }
        else { // 특정 요일 선택/미선택 했을 때, [요일무관] 카테고리 미선택
          let fetchList = fetchList.map { model in
            if model.day == .all {
              return RecruitmentFilterDateCollectionViewCellModel(day: model.day)
            }
            return model
          }
          fetchingDayModel.accept(fetchList)
          confirmList.append(day)
          confirmDay.accept(confirmList)
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
    static let entireName = "전체"
  }
}
