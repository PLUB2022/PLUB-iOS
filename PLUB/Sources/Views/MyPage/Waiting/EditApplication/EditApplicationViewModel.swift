//
//  EditApplicationViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/19.
//

import Foundation

import RxSwift
import RxCocoa

class EditApplicationViewModel {
  private let disposeBag = DisposeBag()
  
  // Input
  let answerText: AnyObserver<[Answer]>
  
  // Output
  let isButtonEnabled: Driver<Bool>
  
  private let answerSubject = PublishSubject<[Answer]>()
  
  init() {
    answerText = answerSubject.asObserver()
    
    isButtonEnabled = answerSubject
      .map { $0.map { $0.answer } }
      .map { !$0.contains("") }
      .asDriver(onErrorDriveWith: .empty())
  }
}
