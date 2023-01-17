//
//  BottomSheetViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

import RxSwift

class BottomSheetViewController: BaseViewController {
  let contentView = UIView().then {
    $0.backgroundColor = .background
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  private let tapGesture = UITapGestureRecognizer(
      target: BottomSheetViewController.self,
      action: nil
  )
  
  init() {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = .clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    presentBottomSheet()
  }
  
  override func setupLayouts() {
    [contentView].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    contentView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
  
  override func bind() {
    tapGesture.rx.event
      .withUnretained(self)
      .asDriver(onErrorDriveWith: .empty())
      .drive(onNext: { _ in
        self.dismissBottomSheet()
      })
      .disposed(by: disposeBag)
    view.addGestureRecognizer(tapGesture)
  }
}

private extension BottomSheetViewController {
  private func presentBottomSheet() {
    contentView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
    UIView.transition(with: view, duration: 0.25, options: .curveEaseInOut, animations: {
      self.view.backgroundColor = .init(hex: 0x000000).withAlphaComponent(0.25)
      self.contentView.frame.origin = CGPoint(x: 0, y: 0)
    })
  }
  
  private func dismissBottomSheet() {
    UIView.transition(with: view, duration: 0.25, options: .curveEaseInOut, animations: {
      self.view.backgroundColor = .clear
      self.contentView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
    }, completion: { _ in
      self.dismiss(animated: false)
    })
  }
}
