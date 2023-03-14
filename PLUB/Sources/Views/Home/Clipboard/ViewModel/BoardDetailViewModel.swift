//
//  BoardDetailViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/03/06.
//

import UIKit

import RxSwift
import RxCocoa

protocol BoardDetailViewModelType {
  // Input
  
  // Output
}

protocol BoardDetailDataStore {
  var content: FeedsContent { get }
  var comments: [CommentContent] { get }
}

final class BoardDetailViewModel: BoardDetailViewModelType, BoardDetailDataStore {
  
  // MARK: - Properties
  
  let content: FeedsContent
  let comments: [CommentContent]
  
  // MARK: - Initializations
  
  init(content: FeedsContent, comments: [CommentContent]) {
    self.content = content
    self.comments = comments
  }
  
  private let disposeBag = DisposeBag()
}
