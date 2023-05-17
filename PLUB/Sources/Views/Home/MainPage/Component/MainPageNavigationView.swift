//
//  MainPageNavigationView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/03.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol MainPageNavigationViewDelegate: AnyObject {
  func didTappedArchiveButton()
  func didTappedNoticeButton()
}

final class MainPageNavigationView: UIStackView {
  
  weak var delegate: MainPageNavigationViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let speakerButton = UIButton().then {
    $0.setImage(UIImage(named: "speakerBlack"), for: .normal)
  }
  
  private let archiveButton = UIButton().then {
    $0.setImage(UIImage(named: "photoStackBlack"), for: .normal)
  }
  
  private let verticalEllipsisBlack = UIButton().then {
    $0.setImage(UIImage(named: "verticalEllipsisBlack"), for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [speakerButton, archiveButton, verticalEllipsisBlack].forEach { addArrangedSubview($0) }
  }
  
  private func bind() {
    speakerButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedNoticeButton()
      }
      .disposed(by: disposeBag)
    
    archiveButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedArchiveButton()
      }
      .disposed(by: disposeBag)
  }
}
