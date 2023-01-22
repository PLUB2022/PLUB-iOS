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
  let sexButtonTapped: AnyObserver<Void>
  let calendarDidSet: AnyObserver<Void>
  
  // output
  let isButtonEnabled: Driver<Bool>
  
  private let calendarSelected = PublishSubject<Void>()
  private let sexSelected = PublishSubject<Void>()
  
  private let disposeBag = DisposeBag()
  
  init() {
    sexButtonTapped = sexSelected.asObserver()
    calendarDidSet = calendarSelected.asObserver()
    isButtonEnabled = Driver.combineLatest(
      sexSelected.asDriver(onErrorDriveWith: .empty()),
      calendarSelected.asDriver(onErrorDriveWith: .empty())
    ) { _, _  in true }
  }
}
