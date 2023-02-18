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
  var selectDetailCell: AnyObserver<Int> { get }
  var deselectDetailCell: AnyObserver<Int> { get }
  var tappedRegisterButton: AnyObserver<Void> { get }
  
  // Output
  var fetchedRegisterInterest: Driver<[RegisterInterestModel]> { get }
  var isEnabledFloatingButton: Driver<Bool> { get }
  var successRegisterInterest: Observable<Void> { get }
}

// TODO: 이건준 -추후 API요청에 따른 result failure에 대한 에러 묶어서 처리하기
final class RegisterInterestViewModel: RegisterInterestViewModelType {
  let disposeBag = DisposeBag()

  // Input
  let selectDetailCell: AnyObserver<Int> // 관심사 등록을 위한 셀을 클릭했는지
  let deselectDetailCell: AnyObserver<Int> // 관심사 등록해제를 위한 셀을 클릭했는지
  let tappedRegisterButton: AnyObserver<Void> // 관심사 등록 버튼을 탭했는지
  
  // Output
  let fetchedRegisterInterest: Driver<[RegisterInterestModel]> // 관심사 등록을 위한 데이터 방출
  let isEnabledFloatingButton: Driver<Bool> // 하나의 셀이라도 눌렸는지에 대한 값 방출
  let successRegisterInterest: Observable<Void> // 관심사 등록 성공여부
  
  init() {
    let fetchingRegisterInterest = BehaviorRelay<[RegisterInterestModel]>(value: [])
    let selectingDetailCellCount = BehaviorSubject<Int>(value: 0)
    let selectingDetailCell = PublishSubject<Int>()
    let deselectingDetailCell = PublishSubject<Int>()
    let selectingInterest = BehaviorRelay<[Int]>(value: [])
    let registering = PublishSubject<Void>()
    
    fetchedRegisterInterest = fetchingRegisterInterest.asDriver(onErrorDriveWith: .empty())
    selectDetailCell = selectingDetailCell.asObserver()
    deselectDetailCell = deselectingDetailCell.asObserver()
    tappedRegisterButton = registering.asObserver()
    
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
      fetchingRegisterInterest.accept(models)
    })
    .disposed(by: disposeBag)
    
    selectingDetailCell.withLatestFrom(selectingDetailCellCount) { ($0, $1) }
      .map{ ($0, $1 + 1) }
      .subscribe(onNext: { categoryID, count in
        var selectInterest = selectingInterest.value
        selectInterest.append(categoryID)
        selectingInterest.accept(selectInterest)
        selectingDetailCellCount.onNext(count)
      })
      .disposed(by: disposeBag)
    
    deselectingDetailCell.withLatestFrom(selectingDetailCellCount) { ($0, $1) }
      .map{ ($0, $1 - 1) }
      .subscribe(onNext: { categoryID, count in
        var selectInterest = selectingInterest.value
        selectInterest.append(categoryID)
        selectingInterest.accept(selectInterest)
        selectingDetailCellCount.onNext(count)
      })
      .disposed(by: disposeBag)
    
    let registerInterest = registering.withLatestFrom(selectingInterest)
      .flatMapLatest { selectInterest in
        return AccountService.shared.registerInterest(request: .init(subCategories: selectInterest))
      }
    
    successRegisterInterest = registerInterest.compactMap { result -> Void? in
      guard case .success(_) = result else { return nil }
      return ()
    }
    
    isEnabledFloatingButton = selectingDetailCellCount.map{ $0 != 0 }.asDriver(onErrorJustReturn: false)
  }
}

