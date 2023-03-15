//
//  RecruitingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/16.
//

import RxSwift
import RxCocoa

class RecruitingViewModel {
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    
    RecruitmentService.shared.inquireApplicant(plubbingID: "\(plubbingID)")
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
