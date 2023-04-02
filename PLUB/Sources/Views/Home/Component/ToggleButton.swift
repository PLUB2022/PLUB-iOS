//
//  IndicatorButton.swift
//  PLUB
//
//  Created by 이건준 on 2022/11/23.
//

import UIKit

import RxSwift
import RxCocoa

enum ToggleType {
  case indicator
  case bookmark
  case chart
  case grid
  case like
  
  var selectedImage: String {
    switch self {
    case .indicator:
      return "topIndicator"
    case .bookmark:
      return "bookmarkActivated"
    case .chart:
      return "chartActivated"
    case .grid:
      return "gridActivated"
    case .like:
      return "heartFilled"
    }
  }
  
  var unSelectedImage: String {
    switch self {
    case .indicator:
      return "bottomIndicator"
    case .bookmark:
      return "bookmarkInActivated"
    case .chart:
      return "chartInActivated"
    case .grid:
      return "gridInActivated"
    case .like:
      return "heart"
    }
  }
}

class ToggleButton: UIButton {
  
  private let type: ToggleType
  private let disposeBag = DisposeBag()
  
  override var isSelected: Bool {
    didSet {
      isSelected ? setImage(UIImage(named: type.selectedImage), for: .normal) : setImage(UIImage(named: type.unSelectedImage), for: .normal)
    }
  }
  
  private var onPlayButtonPressed: Observable<Bool> {
    self.rx.isHighlighted
      .filter { $0 == true }
      .withLatestFrom(self.rx.isSelected)
      .map { !$0 }
  }
  
  var buttonTapObservable: Observable<Void> {
    self.onPlayButtonPressed
      .filter { $0 == false }
      .map { _ in return Void() }
      .asObservable()
  }
  
  var buttonUnTapObservable: Observable<Void> {
    self.onPlayButtonPressed
      .filter { $0 == true }
      .map { _ in return Void() }
      .asObservable()
  }
  
  init(type: ToggleType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    setImage(UIImage(named: type.unSelectedImage), for: .normal)
  }
  
  private func bind() {
    self.onPlayButtonPressed
      .bind(to: self.rx.isSelected)
      .disposed(by: disposeBag)
  }
}

extension Reactive where Base: UIControl {
  public var isHighlighted: Observable<Bool> {
    self.base.rx.methodInvoked(#selector(setter: self.base.isHighlighted))
      .compactMap { $0.first as? Bool }
      .startWith(self.base.isHighlighted)
      .distinctUntilChanged()
      .share()
  }
  public var isSelected: Observable<Bool> {
    self.base.rx.methodInvoked(#selector(setter: self.base.isSelected))
      .compactMap { $0.first as? Bool }
      .startWith(self.base.isSelected)
      .distinctUntilChanged()
      .share()
  }
}
