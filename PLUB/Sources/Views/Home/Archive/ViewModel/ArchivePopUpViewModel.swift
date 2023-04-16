//
//  ArchivePopUpViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/04/15.
//

import UIKit

import RxSwift
import RxCocoa

protocol ArchivePopUpViewModelType {
  // Input
  
  var viewDidLoadObserver: AnyObserver<Void> { get }
  
  // Output
  
  var fetchArchives: Observable<ArchiveContent> { get }
}

final class ArchivePopUpViewModel {
  
  // MARK: - Properties
  
  private let getArchiveDetailUseCase: GetArchiveDetailUseCase
  
  private let viewDidLoadSubject = ReplaySubject<Void>.create(bufferSize: 1)
  
  // MARK: - Initialization
  
  init(getArchiveDetailUseCase: GetArchiveDetailUseCase) {
    self.getArchiveDetailUseCase = getArchiveDetailUseCase
  }
  
  private let disposeBag = DisposeBag()
  
  
  // MARK: - Configuration
  
}

// MARK: - ArchivePopUpViewModelType

extension ArchivePopUpViewModel: ArchivePopUpViewModelType {
  var viewDidLoadObserver: AnyObserver<Void> {
    viewDidLoadSubject.asObserver()
  }
  
  var fetchArchives: Observable<ArchiveContent> {
    viewDidLoadSubject
      .flatMap { [getArchiveDetailUseCase] in getArchiveDetailUseCase.execute() }
      .debug()
  }
}
