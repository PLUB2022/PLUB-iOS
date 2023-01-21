//
//  ProfileViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/20.
//

import Foundation

import RxCocoa
import RxSwift

final class ProfileViewModel {
  private let disposeBag = DisposeBag()
  
  private let isAvailableRelay = PublishRelay<Bool>()
  private let alertMessageRelay = PublishRelay<String>()
}
