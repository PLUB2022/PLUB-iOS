//
//  CompleteTodolistResponse.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/04.
//

import Foundation

struct CompleteProofTodolistResponse: Codable {
  
  /// 투두를 나타내는 아이디 값
  let todoID: Int
  
  /// 투두 완성 혹은 인증을 하고싶은 투두의 콘텐츠
  let content: String
  
  /// 투두가 작성된 일자
  let date: String
  
  /// 해당 투두를 체크했는지 안했는지에 대한 여부
  let isChecked: Bool
  
  /// 해당 투두가 인증이 된 투두인지 아닌지에 대한 여부
  let isProof: Bool
  
  /// 투두 인증모달 이미지 값
  ///
  /// 투두 인증에 성공하여 인증성공모달을 띄어줄때 해당 값을 이용하여 이미지를 띄어줍니다.
  let proofImage: String
  
  /// 해당 투두의 작성자인지 아닌지에 대한 여부
  let isAuthor: Bool
  
  enum CodingKeys: String, CodingKey {
    case todoID = "todoId"
    case content, date, isChecked, isProof, proofImage, isAuthor
  }
}
