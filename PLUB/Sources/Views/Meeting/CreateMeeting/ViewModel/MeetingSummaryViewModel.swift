//
//  MeetingSummaryViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import RxSwift
import RxCocoa
import UIKit

final class MeetingSummaryViewModel {
  private let disposeBag = DisposeBag()
  
  let meetingData: CreateMeetingRequest
  let mainImage: UIImage?
  let categoryNames: [String]
  let time: String
  
  init(
    meetingData: CreateMeetingRequest,
    mainImage: UIImage?,
    categoryNames: [String],
    time: String
  ) {
    self.meetingData = meetingData
    self.mainImage = mainImage
    self.categoryNames = categoryNames
    self.time = time
  }
  
  func createMeeting() {
    MeetingService.shared
      .createMeeting(request: meetingData)
      .withUnretained(self)
      .subscribe(onNext: { owner, result in
        switch result {
        case .success(let data):
          print(data.data?.plubbingID)
        default:
          break
        }
      })
      .disposed(by: disposeBag)
  }
}
