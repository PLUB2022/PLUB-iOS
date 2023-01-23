//
//  IntroductionViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/23.
//

import Foundation

import RxCocoa
import RxSwift

protocol IntroductionViewModelType: IntroductionViewModel {
  // Input
  var introductionText: AnyObserver<String> { get }
  
  // Output
  var isButtonEnabled: Driver<Bool> { get }
}

final class IntroductionViewModel: IntroductionViewModelType {
  
  // Input
  let introductionText: AnyObserver<String>
  
  // Output
  let isButtonEnabled: Driver<Bool> // 버튼 활성화 여부
  
  
  private let textSubject = PublishSubject<String>()
  
  private let disposeBag = DisposeBag()
  
  
  init() {
    introductionText = textSubject.asObserver()
    
    isButtonEnabled = textSubject
      .map { $0.isEmpty == false } // 값이 존재해야 버튼 활성화
      .debug()
      .asDriver(onErrorDriveWith: .empty())
  }
}
