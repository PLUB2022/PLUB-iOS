//
//  MeetingCategoryViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/29.
//

import RxSwift
import RxCocoa

final class MeetingCategoryViewModel: RegisterInterestViewModelType {
  private let disposeBag = DisposeBag()

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
