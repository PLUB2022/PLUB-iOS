//
//  MeetingCategoryViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/29.
//

import RxSwift
import RxCocoa

final class MeetingCategoryViewModel {
  
  // Input
  let selectSubCategory: AnyObserver<SubCategory>   // 선택된 서브 카테고리
  let deselectSubCategory: AnyObserver<Int> // 취소한 카테고리의 id
  
  // Output
  let fetchData: Driver<[RegisterInterestModel]>  // tableView data fetch
  let selectedSubCategories: Driver<[SubCategory]>        // 선택된 서브 카테고리의 배열
  let isButtonEnabled: Driver<Bool>               // 버튼 활성화 여부
  let selectedSubCategoriesCount: Driver<Int>     // 선택된 카테고리 개수
  var selectEnabled: Bool = true                  // 카테고리 선택 활성화 여부 (5개 이하 제한)
  
  /// fetch한 카테고리 데이터
  private let fetchedCategoriesRelay = BehaviorRelay<[RegisterInterestModel]>(value: [])
  
  /// 선택된 카테고리의 `Subject`
  private let selectSubject = PublishSubject<SubCategory>()
  
  /// 취소된 카테고리의 `Subject`
  private let deselectSubject = PublishSubject<Int>()
  
  /// 선택된 카테고리들의 `Relay`
  private let selectedSubCategoriesRelay = BehaviorRelay<[SubCategory]>(value: [])
  
  /// 선택된 카테고리 개수의 `Relay`
  private let selectedSubCategoriesCountRelay = BehaviorRelay<Int>(value: 0)
  
  private let disposeBag = DisposeBag()
  
  init() {
    fetchData = fetchedCategoriesRelay.asDriver()
    selectSubCategory = selectSubject.asObserver()
    deselectSubCategory = deselectSubject.asObserver()
   
    selectedSubCategories = selectedSubCategoriesRelay.asDriver()
    selectedSubCategoriesCount = selectedSubCategoriesCountRelay.asDriver()
    
    isButtonEnabled = selectedSubCategoriesRelay
      .map { $0.count != 0 }
      .asDriver(onErrorJustReturn: false)
    
    bind()
  }
  
  private func bind() {
    CategoryService.shared.inquireAll()
      .compactMap { result -> [Category]? in
        guard case let .success(allCategoryResponse) = result else { return nil }
        return allCategoryResponse.data?.categories
      }
      .map { return $0.map { RegisterInterestModel(category: $0) } }
      .bind(to: fetchedCategoriesRelay)
      .disposed(by: disposeBag)
    
    selectSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, value in
        var array = owner.selectedSubCategoriesRelay.value
        array.append(value)
        owner.selectedSubCategoriesRelay.accept(array) // 선택된 카테고리 업데이트
        owner.selectedSubCategoriesCountRelay.accept(array.count) // 선택된 카테고리 개수 업데이트
        if array.count > 4 {
          owner.selectEnabled = false // 카테고리 선택 제한
        }
      })
      .disposed(by: disposeBag)
    
    deselectSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, value in
        let array = owner.selectedSubCategoriesRelay.value.filter { $0.id != value }
        owner.selectedSubCategoriesRelay.accept(array) // 선택된 카테고리 업데이트
        owner.selectedSubCategoriesCountRelay.accept(array.count) // 선택된 카테고리 개수
        if array.count < 5 {
          owner.selectEnabled = true // 카테고리 선택 제한 해제
        }
      })
      .disposed(by: disposeBag)
  }
}
