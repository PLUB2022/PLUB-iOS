//
//  BirthViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/22.
//

import Foundation

import RxCocoa
import RxSwift

protocol BirthViewModelType: BirthViewModel {
  // input
  var sexButtonTapped: AnyObserver<Void> { get }
  var calendarDidSet: AnyObserver<Void> { get }
  
  // output
  var isButtonEnabled: Driver<Bool> { get }
}

final class BirthViewModel: BirthViewModelType {
  
  // input
  let sexButtonTapped: AnyObserver<Void>  // 성별 세팅완료 탭
  let calendarDidSet: AnyObserver<Void>   // 캘린더 세팅완료 탭
  
  // output
  let isButtonEnabled: Driver<Bool>       // 버튼 활성화 여부
  
  private let calendarSelected = PublishSubject<Void>()
  private let sexSelected = PublishSubject<Void>()
  
  private let disposeBag = DisposeBag()
  
  init() {
    sexButtonTapped = sexSelected.asObserver()
    calendarDidSet = calendarSelected.asObserver()
    
    // 두 input이 전부 활성화되었다면 바로 활성화 처리
    // input은 전부 비활성화될 수가 없기 떄문
    isButtonEnabled = Driver.combineLatest(
      sexSelected.asDriver(onErrorDriveWith: .empty()),
      calendarSelected.asDriver(onErrorDriveWith: .empty())
    ) { _, _  in true }
  }
}
