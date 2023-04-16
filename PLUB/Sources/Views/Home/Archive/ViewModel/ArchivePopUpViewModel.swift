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
  
  // Output
}

final class ArchivePopUpViewModel {
  
  // MARK: - Properties
  
  private let getArchiveDetailUseCase: GetArchiveDetailUseCase
  
  // MARK: - Initialization
  
  init(getArchiveDetailUseCase: GetArchiveDetailUseCase) {
    self.getArchiveDetailUseCase = getArchiveDetailUseCase
  }
  
  private let disposeBag = DisposeBag()
  
  
  // MARK: - Configuration
  
}

// MARK: - ArchivePopUpViewModelType

extension ArchivePopUpViewModel: ArchivePopUpViewModelType {

}
