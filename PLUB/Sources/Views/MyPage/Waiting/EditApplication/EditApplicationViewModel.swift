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
  let editButtonTapped: AnyObserver<Void>
  
  // Output
  let editButtonEnabled: Driver<Bool>
  
  private let answerSubject = PublishSubject<[Answer]>()
  private let editButtonTappedSubject = PublishSubject<Void>()
  init() {
    answerText = answerSubject.asObserver()
    editButtonTapped = editButtonTappedSubject.asObserver()
    
    editButtonEnabled = answerSubject
      .map { $0.map { $0.answer } }
      .map { !$0.contains("") }
      .asDriver(onErrorDriveWith: .empty())
    
    editButtonTappedSubject
      .withLatestFrom(answerSubject)
      .subscribe(onNext: { anwers in
        
      })
      .disposed(by: disposeBag)
  }
}
