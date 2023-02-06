//
//  RegisterInterestViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import RxSwift
import RxCocoa

protocol RegisterInterestViewModelType {
  // Input
  var selectDetailCell: AnyObserver<Void> { get }
  var deselectDetailCell: AnyObserver<Void> { get }
  
  // Output
  var fetchedRegisterInterest: Driver<[RegisterInterestModel]> { get }
  var isEnabledFloatingButton: Driver<Bool> { get }
}

final class RegisterInterestViewModel: RegisterInterestViewModelType {
  let disposeBag = DisposeBag()

  // Input
  let selectDetailCell: AnyObserver<Void> // 관심사 등록을 위한 셀을 클릭했는지
  let deselectDetailCell: AnyObserver<Void> // 관심사 등록해제를 위한 셀을 클릭했는지
  
  // Output
  let fetchedRegisterInterest: Driver<[RegisterInterestModel]> // 관심사 등록을 위한 데이터 방출
  let isEnabledFloatingButton: Driver<Bool> // 하나의 셀이라도 눌렸는지에 대한 값 방출
  
  init() {
    let fetchingRegisterInterest = BehaviorSubject<[RegisterInterestModel]>(value: [])
    let selectingDetailCellCount = BehaviorSubject<Int>(value: 0)
    let selectingDetailCell = PublishSubject<Void>()
    let deselectingDetailCell = PublishSubject<Void>()
    fetchedRegisterInterest = fetchingRegisterInterest.asDriver(onErrorDriveWith: .empty())
    selectDetailCell = selectingDetailCell.asObserver()
    deselectDetailCell = deselectingDetailCell.asObserver()
    
    let inquireAllCategoryList = CategoryService.shared.inquireAll().share()
    let successFetching = inquireAllCategoryList.map { result -> [Category]? in
      guard case .success(let allCategoryResponse) = result else { return nil }
      return allCategoryResponse.data?.categories
    }
    
    successFetching.subscribe(onNext: { categories in
      guard let categories = categories else { return }
      let models = categories.map { category in
        return RegisterInterestModel(category: category)
      }
      fetchingRegisterInterest.onNext(models)
    })
    .disposed(by: disposeBag)
    
    selectingDetailCell.withLatestFrom(selectingDetailCellCount)
      .map{ $0 + 1 }
      .subscribe(onNext: selectingDetailCellCount.onNext(_:))
      .disposed(by: disposeBag)
    
    deselectingDetailCell.withLatestFrom(selectingDetailCellCount)
      .map{ $0 - 1 }
      .subscribe(onNext: selectingDetailCellCount.onNext(_:))
      .disposed(by: disposeBag)
    
    isEnabledFloatingButton = selectingDetailCellCount.map{ $0 != 0 }.asDriver(onErrorJustReturn: false)
  }
}

