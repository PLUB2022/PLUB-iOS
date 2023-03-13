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
  // Intput
  var selectPlubbingID: AnyObserver<Int> { get }
  
  func createMockData() -> Observable<[MockModel]>
}

/// 게시판에 관련된 클립보드리스트가 존재하는지에 대한 여부 BoardHeaderViewType Output 필요
///  클립보드에 관련된 리스트가 몇개인지에 대한 ClipboardType Output 필요
final class BoardViewModel: BoardViewModelType {
  
  private let disposeBag = DisposeBag()
  
  // Input
  let selectPlubbingID: AnyObserver<Int>
  
  // Output
  
  init() {
    let selectingPlubbingID = PublishSubject<Int>()
    self.selectPlubbingID = selectingPlubbingID.asObserver()
    
    // Input
    let fetchingBoards = selectingPlubbingID
      .flatMapLatest { plubbingID in
        return FeedsService.shared.fetchBoards(plubbingID: plubbingID)
      }
    
    let successFetchingBoards = fetchingBoards.compactMap { result -> [FeedsContent]? in
      guard case .success(let response) = result else { return nil }
      return response.data?.content
    }
    
    successFetchingBoards.subscribe(onNext: { content in
      print("콘텐츠 \(content)")
    })
    .disposed(by: disposeBag)
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
