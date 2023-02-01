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
  
  init(
    meetingData: CreateMeetingRequest,
    mainImage: UIImage?
  ) {
    self.meetingData = meetingData
    self.mainImage = mainImage
  }
}
