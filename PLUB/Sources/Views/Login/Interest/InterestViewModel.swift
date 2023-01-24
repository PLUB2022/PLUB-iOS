//
//  InterestViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/23.
//

import RxSwift
import RxCocoa

final class InterestViewModel {
  
  // Input
  let selectSubCategory: AnyObserver<Int>   // 선택된 카테고리의 id
  let deselectSubCategory: AnyObserver<Int> // 취소한 카테고리의 id
  
  // Output
  let fetchData: Driver<[RegisterInterestModel]>  // tableView data fetch
  let selectedSubCategories: Driver<[Int]>        // 선택된 카테고리의 id 배열
  let isButtonEnabled: Driver<Bool>               // 버튼 활성화 여부
  
  /// fetch한 카테고리 데이터
  private let fetchedCategoriesSubject = BehaviorSubject<[RegisterInterestModel]>(value: [])
  
  /// 선택된 카테고리의 `Subject`
  private let selectSubject = PublishSubject<Int>()
  
  /// 취소된 카테고리의 `Subject`
  private let deselectSubject = PublishSubject<Int>()
  
  /// 선택된 카테고리의 `Relay`
  private let selectedSubCategoriesRelay = BehaviorRelay<[Int]>(value: [])
  
  private let disposeBag = DisposeBag()
  
  init() {
    fetchData = fetchedCategoriesSubject.asDriver(onErrorDriveWith: .empty())
    selectSubCategory = selectSubject.asObserver()
    deselectSubCategory = deselectSubject.asObserver()
    isButtonEnabled = selectedSubCategoriesRelay
      .map { $0.count != 0 }
      .asDriver(onErrorJustReturn: false)
    selectedSubCategories = selectedSubCategoriesRelay.asDriver()
  }
}
