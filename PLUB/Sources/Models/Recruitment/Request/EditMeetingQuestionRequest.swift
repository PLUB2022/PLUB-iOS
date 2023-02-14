//
//  EditMeetingQuestionRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/12.
//

import Foundation

struct EditMeetingQuestionRequest: Codable {
  /// 질문 리스트
  var questions: [String]
  
  init() {
    questions = []
  }
  
  init(questions: [String]) {
    self.questions = questions
  }
}

extension EditMeetingQuestionRequest {
  enum CodingKeys: String, CodingKey {
    case questions
  }
}
