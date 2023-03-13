//
//  MyPageViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa

final class MyPageViewModel {
  private let disposeBag = DisposeBag()
  
  // Output
  let myInfo: Driver<MyInfoResponse>
  let tableViewReload: Driver<Void>
  
  private let myInfoSubject = PublishSubject<MyInfoResponse>()
  private let tableViewReloadSubject = PublishSubject<Void>()
  
  // Data
  private(set) var myPlubbing: [MyPlubbingResponse] = []
  
  init() {
    myInfo = myInfoSubject.asDriver(onErrorDriveWith: .empty())
    tableViewReload = tableViewReloadSubject.asDriver(onErrorDriveWith: .empty())
    
    let plubbingStatusTypes = PlubbingStatusType.allCases.map {
      return MyPageService.shared.inquireMyMeeting(
        status: $0,
        cursorID: 0
      )
    }
    
    // 플러빙 타입 4가지 API 동시 호출
    let successMyPubbings = Observable.zip(plubbingStatusTypes)
      .map {
        $0.compactMap { result -> MyPlubbingResponse? in
          guard case .success(let model) = result else { return nil }
          return model.data
        }
      }

    successMyPubbings
      .withUnretained(self)
      .subscribe(onNext: { owner, responses in
        for response in responses {
          guard !response.plubbings.isEmpty else { break }
          // 플러빙이 비어있지 않을 때만 섹션 추가
          owner.myPlubbing.append(response)
        }
        
        // 테이블 뷰 리로드
        owner.tableViewReloadSubject.onNext(())
      }, onError: { error in
          print("")
      })
      .disposed(by: disposeBag)
  }
  
  
  func fetchMyInfoData() {
    AccountService.shared.inquireMyInfo()
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
          owner.myInfoSubject.onNext(data)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
