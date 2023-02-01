//
//  MeetingSummaryViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/01.
//

import RxSwift
import RxCocoa

final class MeetingSummaryViewModel {
  private let disposeBag = DisposeBag()
  
  let meetingData: CreateMeetingRequest
  
  init(meetingData: CreateMeetingRequest) {
    self.meetingData = meetingData
    print(meetingData)
  }
}
