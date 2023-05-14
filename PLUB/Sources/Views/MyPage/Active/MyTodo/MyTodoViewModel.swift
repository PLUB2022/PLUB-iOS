//
//  MyTodoViewModel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/05/14.
//

import UIKit

import RxSwift
import RxCocoa

protocol MyTodoViewModelType {
  // MARK: Property
  var plubbingID: Int { get }
  var todoList: [TodoContent] { get }
  
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> { get }
  
  // MARK: Output
  var reloadTaleViewDriver: Driver<Void> { get } // 테이블 뷰 리로드
}

final class MyTodoViewModel {
  private let disposeBag = DisposeBag()
  
  // MARK: Property
  private(set) var plubbingID: Int
  private(set) var todoList = [TodoContent]()
  private let pagingManager = PagingManager<TodoContent>(threshold: 700)
  
  // MARK: UseCase
  private let inquireMyTodoUseCase: InquireMyTodoUseCase
  
  // MARK: Subjects
  private let offsetSubject = PublishSubject<(tableViewHeight: CGFloat, offset: CGFloat)>()
  private let reloadTaleViewSubject = PublishSubject<Void>()
  
  init(
    plubbingID: Int,
    inquireMyTodoUseCase: InquireMyTodoUseCase
  ) {
    self.plubbingID = plubbingID
    self.inquireMyTodoUseCase = inquireMyTodoUseCase
    
    pagingSetup(plubbingID: plubbingID)
  }
  
  private func pagingSetup(plubbingID: Int) {
    offsetSubject
      .filter { [pagingManager] in
        return pagingManager.shouldFetchNextPage(totalHeight: $0, offset: $1)
      }
      .flatMap { [weak self] _ -> Observable<[TodoContent]> in
        guard let self else { return .empty() }
        return self.pagingManager.fetchNextPage { cursorID in
          self.inquireMyTodoUseCase.execute(plubbingID: plubbingID, cursorID: cursorID)
            .map { data in
              (
                content: data.todoInfo.todoContent,
                nextCursorID: data.todoInfo.todoContent.last?.todoID ?? 0,
                isLast: data.todoInfo.last
              )
            }
        }
      }
      .subscribe(with: self) { owner, content in
        owner.todoList.append(contentsOf: content)
        owner.reloadTaleViewSubject.onNext(())
      }
      .disposed(by: disposeBag)
  }
}

extension MyTodoViewModel: MyTodoViewModelType {
  // MARK: Input
  var offsetObserver: AnyObserver<(tableViewHeight: CGFloat, offset: CGFloat)> {
    offsetSubject.asObserver()
  }
  
  // MARK: Output
  var reloadTaleViewDriver: Driver<Void> { reloadTaleViewSubject.asDriver(onErrorDriveWith: .empty())
  }
}
