//
//  BoardViewModel.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/02.
//

import RxSwift
import RxCocoa
import Foundation

protocol BoardViewModelType {
  func createMockData() -> Observable<[MockModel]>
}

final class BoardViewModel: BoardViewModelType {
  
  // Input
  
  
  // Output
  
  init() {
    
  }
  
  func createMockData() -> Observable<[MockModel]> {
    return Observable.just([
      MockModel(type: .photo, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
      MockModel(type: .text, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
      MockModel(type: .photoAndText, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
//      MockModel(type: .photoAndText, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
//      MockModel(type: .text, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
//      MockModel(type: .text, viewType: .pin, content: "안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요안녕하세요ㅇ", feedImageURL: "https://plub.s3.ap-northeast-2.amazonaws.com/plubbing/mainImage/sports1.png"),
    ])
  }
}

struct MockModel {
  let type: PostType
  let viewType: ViewType
  let content: String
  let feedImageURL: String?
}
