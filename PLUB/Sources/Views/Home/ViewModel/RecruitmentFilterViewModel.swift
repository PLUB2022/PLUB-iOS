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

final class RecruitmentFilterViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let selectingSubCategories = BehaviorRelay<[RecruitmentFilterCollectionViewCellModel]>(value: [])
  private let fetchingDayModel = BehaviorRelay<[RecruitmentFilterDateCollectionViewCellModel]>(value: [])
  private let isSelectingSubCategory = PublishSubject<(Bool, Int)>()
  private let isSelectingDay = PublishSubject<(Bool, Day)>()
  private let confirmSubCategory = BehaviorRelay<[Int]>(value: [])
  private let confirmDay = BehaviorRelay<[Day]>(value: [])
  private let filterConfirming = PublishSubject<Void>()
  private let confirmingAccountNum = BehaviorSubject<Int>(value: 4)
  
  init(categoryID: Int) {
    initializeFetchingDay()
    fetchSubCategory(categoryID: categoryID)
    selectingSubCategory()
    selectingDay()
  }
  
  private func initializeFetchingDay() { // 요일에 대한 상태값을 초기화하는 함수
    let fetchDay = Day.allCases.map { RecruitmentFilterDateCollectionViewCellModel(day: $0) }
    fetchingDayModel.accept(fetchDay)
  }
  
  private func fetchSubCategory(categoryID: Int) {
    let requestSubCategory = CategoryService.shared.inquireSubCategoryList(categoryID: categoryID)
    
    let successRequestSubCategory = requestSubCategory.compactMap { result -> [SubCategory]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.categories
    }
    
    successRequestSubCategory.map { subCategories in
      return subCategories.map { RecruitmentFilterCollectionViewCellModel(subCategory: $0) }
    }
    .subscribe(with: self) { owner, subCategories in
      var subCategories = subCategories
      subCategories.insert(RecruitmentFilterCollectionViewCellModel(
        subCategoryID: Constants.entireID,
        name: Constants.entireName,
        isTapped: false
      ), at: 0)
      owner.selectingSubCategories.accept(subCategories)
    }
    .disposed(by: disposeBag)
  }
  
  private func selectingSubCategory() {
    // 서브카테고리를 선택함에 따른 동작
    isSelectingSubCategory
      .subscribe(with: self) { owner, subCategoryInfo in
        let (isSelect, subCategoryID) = subCategoryInfo
        var confirmList = owner.confirmSubCategory.value
        var fetchList = owner.selectingSubCategories.value
        
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
          owner.selectingSubCategories.accept(fetchList)
          owner.confirmSubCategory.accept([])
        }
        else { // 특정 서브카테고리를 선택/미선택 했을 때, [전체] 카테고리 미선택
          fetchList[0].isTapped = false
          owner.selectingSubCategories.accept(fetchList)
          confirmList.append(subCategoryID)
          owner.confirmSubCategory.accept(confirmList)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func selectingDay() {
    // 요일을 선택함에 따른 동작
    isSelectingDay
      .subscribe(with: self) { owner, selectInfo in
        let (isSelect, day) = selectInfo
        
        var confirmList = owner.confirmDay.value
        var fetchList = owner.fetchingDayModel.value
        
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
          owner.fetchingDayModel.accept(fetchList)
          owner.confirmDay.accept([])
        }
        else { // 특정 요일 선택/미선택 했을 때, [요일무관] 카테고리 미선택
          fetchList[0].isTapped = false
          owner.fetchingDayModel.accept(fetchList)
          confirmList.append(day)
          owner.confirmDay.accept(confirmList)
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Input & Output
extension RecruitmentFilterViewModel: RecruitmentFilterViewModelType {
  
  // Input
  var isSelectSubCategory: AnyObserver<(Bool, Int)> { // 세부카테고리 선택/미선택
    isSelectingSubCategory.asObserver()
  }
  
  var isSelectDay: AnyObserver<(Bool, Day)> { // 요일 선택/미선택
    isSelectingDay.asObserver()
  }
  
  var filterConfirm: AnyObserver<Void> { // 필터클릭
    filterConfirming.asObserver()
  }
  
  var confirmAccountNum: AnyObserver<Int> { // 필터하고자하는 인원 수
    confirmingAccountNum.asObserver()
  }
  
  // Output
  var selectedSubCategories: Signal<[RecruitmentFilterCollectionViewCellModel]> { // 선택된 서브카테고리 목록
    selectingSubCategories.asSignal(onErrorSignalWith: .empty())
  }
  
  var fetchedDayModel: Signal<[RecruitmentFilterDateCollectionViewCellModel]> {
    fetchingDayModel.asSignal(onErrorSignalWith: .empty())
  }
  
  var isButtonEnabled: Driver<Bool> { // 필터버튼 활성화 여부
    Observable.combineLatest(
      selectingSubCategories,
      fetchingDayModel
    )
    { subCategories, days in
      return subCategories.filter(\.isTapped).count > 0 && days.filter(\.isTapped).count > 0
    }
    .asDriver(onErrorDriveWith: .empty())
  }
  
  var confirmRequest: Signal<CategoryMeetingRequest> {
    filterConfirming.withLatestFrom(
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
  }
}

// MARK: - Constants
extension RecruitmentFilterViewModel { // 서브카테고리 [전체]을 위한 상수
  struct Constants {
    static let entireID = 0
    static let entireName = "전체"
  }
}
