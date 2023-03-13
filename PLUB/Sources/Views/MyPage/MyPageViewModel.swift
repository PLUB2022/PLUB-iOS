//
//  MyPageViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/12.
//

import UIKit

import RxSwift
import RxCocoa

struct MyPageTableViewCellModel {
  let section: MyPlubbingResponse
  var isFolded: Bool
}

final class MyPageViewModel {
  private let disposeBag = DisposeBag()
  
  // Input
  let sectionTapped: AnyObserver<Int> // 섹션뷰 클릭 이벤트
  
  // Output
  let myInfo: Driver<MyInfoResponse> // 내 정보 데이터
  let reloadData: Driver<Void> // 테이블 뷰 갱신
  let reloadSection: Driver<Int> // 테이블 뷰 섹션 갱신
  
  private let sectionTappedSubject = PublishSubject<Int>()
  private let myInfoSubject = PublishSubject<MyInfoResponse>()
  private let reloadDataSubject = PublishSubject<Void>()
  private let reloadSectionSubject = PublishSubject<Int>()
  
  // Data
  private(set) var myPlubbing: [MyPageTableViewCellModel] = [] // 나의 플러빙 데이터
  
  init() {
    sectionTapped = sectionTappedSubject.asObserver()
    
    myInfo = myInfoSubject.asDriver(onErrorDriveWith: .empty())
    reloadData = reloadDataSubject.asDriver(onErrorDriveWith: .empty())
    reloadSection = reloadSectionSubject.asDriver(onErrorDriveWith: .empty())
    
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
          owner.myPlubbing.append(
            .init(section: response, isFolded: true)
          )
        }
        
        // 테이블 뷰 리로드
        owner.reloadDataSubject.onNext(())
      }, onError: { error in
          print("")
      })
      .disposed(by: disposeBag)
    
    sectionTappedSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, index in
        owner.myPlubbing[index].isFolded.toggle()
        owner.reloadSectionSubject.onNext(index)
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
