//
//  WaitingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/02.
//

import RxSwift
import RxCocoa

class WaitingViewModel {
  private let disposeBag = DisposeBag()
  private(set) var plubbingID: Int
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
  }
}
