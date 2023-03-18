//
//  RecruitingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/16.
//

import RxSwift
import RxCocoa
import Foundation

class RecruitingViewModel {
  private let disposeBag = DisposeBag()
  private let plubbingID: Int
  
  // Input
  let sectionTapped: AnyObserver<Int> // 섹션뷰 클릭 이벤트
  let approvalApplicant: AnyObserver<(sectionIndex: Int, accountID: Int)> // 지원자 승낙
  let refuseApplicant: AnyObserver<(sectionIndex: Int, accountID: Int)> // 지원자 거절
  
  // Output
  let meetingInfo: Driver<RecruitingModel> // 내 정보 데이터
  let reloadData: Driver<Void> // 테이블 뷰 갱신
  let reloadSection: Driver<Int> // 테이블 뷰 섹션 갱신
  
  private let sectionTappedSubject = PublishSubject<Int>()
  private let approvalApplicantSubject = PublishSubject<(sectionIndex: Int, accountID: Int)>()
  private let refuseApplicantSubject = PublishSubject<(sectionIndex: Int, accountID: Int)>()
  private let meetingInfoSubject = PublishSubject<RecruitingModel>()
  private let reloadDataSubject = PublishSubject<Void>()
  private let reloadSectionSubject = PublishSubject<Int>()
  
  // Data
  private(set) var applications: [(data: Application, isFolded: Bool)] = []
  
  init(plubbingID: Int) {
    self.plubbingID = plubbingID
    
    sectionTapped = sectionTappedSubject.asObserver()
    approvalApplicant = approvalApplicantSubject.asObserver()
    refuseApplicant = refuseApplicantSubject.asObserver()
    
    meetingInfo = meetingInfoSubject.asDriver(onErrorDriveWith: .empty())
    reloadData = reloadDataSubject.asDriver(onErrorDriveWith: .empty())
    reloadSection = reloadSectionSubject.asDriver(onErrorDriveWith: .empty())
    
    fetchMeetingData()
    fetchApplicants()
    
    sectionTappedSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, index in
        owner.applications[index].isFolded.toggle()
        owner.reloadSectionSubject.onNext(index)
      })
      .disposed(by: disposeBag)
    
    approvalApplicantSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        owner.approvalApplicant(
          sectionIndex: data.sectionIndex,
          accountID: data.accountID
        )
      })
      .disposed(by: disposeBag)
    
    refuseApplicantSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, data in
        owner.refuseApplicant(
          sectionIndex: data.sectionIndex,
          accountID: data.accountID
        )
      })
      .disposed(by: disposeBag)
  }
  
  private func fetchMeetingData() {
    RecruitmentService.shared.inquireDetailRecruitment(plubbingID: "\(plubbingID)")
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          guard let data = model.data else { return }
        
          owner.meetingInfoSubject.onNext(
            RecruitingModel(
              title: data.title,
              schedule: owner.createScheduleString(
                days: data.days,
                time: data.time
              ),
              address: data.address)
          )
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func fetchApplicants() {
    RecruitmentService.shared.inquireApplicant(plubbingID: "\(plubbingID)")
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          guard let data = model.data else { return }
          owner.applications = data.applications.map{ return ($0, true) }
          // 테이블 뷰 리로드
          owner.reloadDataSubject.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func createScheduleString(days: [String], time: String) -> String {
    let dateStr = days
      .joined(separator: ", ")
    
    let date = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
      $0.locale = Locale(identifier: "ko_KR")
    }.date(from: time) ?? Date()

    let timeStr = DateFormatter().then {
      $0.dateFormat = "a h시 m분"
      $0.locale = Locale(identifier: "ko_KR")
    }.string(from: date)
    
    return (dateStr.isEmpty ? "온라인" : dateStr)  + " | " + timeStr
  }
  
  private func approvalApplicant(sectionIndex: Int, accountID: Int) {
    RecruitmentService.shared.approvalApplicant(
      plubbingID: "\(plubbingID)",
      accountID: "\(accountID)"
    )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          owner.applications.remove(at: sectionIndex)
          // 테이블 뷰 리로드
          owner.reloadDataSubject.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func refuseApplicant(sectionIndex: Int, accountID: Int) {
    RecruitmentService.shared.refuseApplicant(
      plubbingID: "\(plubbingID)",
      accountID: "\(accountID)"
    )
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let model):
          print(model)
          owner.applications.remove(at: sectionIndex)
          // 테이블 뷰 리로드
          owner.reloadDataSubject.onNext(())
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
