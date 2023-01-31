//
//  CreateMeetingViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import RxSwift

final class CreateMeetingViewModel {
  private let disposeBag = DisposeBag()
  
  init() {
  }
  
  func createMeeting(
    categoryViewModel: MeetingCategoryViewModel,
    nameViewModel: MeetingNameViewModel,
    introduceViewModel: MeetingIntroduceViewModel,
    dateViewModel: MeetingDateViewModel,
    locationViewModel: MeetingLocationViewModel,
    pepleNumber: MeetingPeopleNumberViewModel,
    questionViewModel: MeetingQuestionViewModel
  ) {
    
  }
}
