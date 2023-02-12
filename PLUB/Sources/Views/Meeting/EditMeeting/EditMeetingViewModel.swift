//
//  EditMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/12.
//

import Foundation

class EditMeetingViewModel {
  let recruitPostViewModel: RecruitPostViewModel
  let meetingInfoViewModel: MeetingInfoViewModel
  let guestQuestionViewModel: GuestQuestionViewModel
  
  init(plubbingID: String) {
    recruitPostViewModel = RecruitPostViewModel(plubbingID: plubbingID)
    meetingInfoViewModel = MeetingInfoViewModel(plubbingID: plubbingID)
    guestQuestionViewModel = GuestQuestionViewModel()
  }
}
