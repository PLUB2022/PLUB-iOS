//
//  MeetingPeopleNumberViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//

import RxSwift
import RxRelay

final class MeetingPeopleNumberViewModel {
  private let disposeBag = DisposeBag()
  
  let peopleNumber = BehaviorRelay<Int>.init(value: .init())
}
