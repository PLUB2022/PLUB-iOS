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

class RegisterInterestViewModel: RegisterInterestViewModelType {
  var disposeBag = DisposeBag()

  // Input
  var selectDetailCell: AnyObserver<Void>
  var deselectDetailCell: AnyObserver<Void>
  
  // Output
  var fetchedRegisterInterest: Driver<[RegisterInterestModel]>
  var isEnabledFloatingButton: Driver<Bool> // 하나의 셀이라도 눌렸는지에 대한 값 방출
  
  init() {
    let fetchingRegisterInterest = BehaviorSubject<[RegisterInterestModel]>(value: [])
    let selectingDetailCellCount = BehaviorSubject<Int>(value: 0)
    let selectingDetailCell = PublishSubject<Void>()
    let deselectingDetailCell = PublishSubject<Void>()
    self.fetchedRegisterInterest = fetchingRegisterInterest.asDriver(onErrorDriveWith: .empty())
    self.selectDetailCell = selectingDetailCell.asObserver()
    self.deselectDetailCell = deselectingDetailCell.asObserver()
    
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

