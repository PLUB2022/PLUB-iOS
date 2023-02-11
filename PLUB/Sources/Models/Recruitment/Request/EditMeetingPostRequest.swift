//
//  EditMeetingPostRequest.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/12.
//

import Foundation

struct EditMeetingPostRequest: Codable {
  /// 플러빙 타이틀
  var title: String
  
  /// 플러빙 이름
  var name: String
  
  /// 플러빙 목표
  var goal: String
  
  /// 소개
  var introduce: String
  
  /// 메인 이미지
  var mainImage: String?
  
  init() {
    title = ""
    name = ""
    goal = ""
    introduce = ""
  }
}

extension EditMeetingPostRequest {
  enum CodingKeys: String, CodingKey {
    case title, name, goal, introduce, mainImage
  }
}
