//
//  MyPageNoneView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/18.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol MyPageNoneViewDelegate: AnyObject {
  func didTappedMoveToMeeting()
}

class MyPageNoneView: UIView {
  
  weak var delegate: MyPageNoneViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let stackView = UIStackView().then {
    $0.spacing = 16
    $0.axis = .vertical
    $0.alignment = .center
  }
  
  private let alertImageView = UIImageView().then {
    $0.image = UIImage(named: "speaker")
    $0.contentMode = .scaleAspectFit
  }
  
  private let alertLabel = UILabel().then {
    $0.font = .subtitle
    $0.textColor = .black
    $0.textAlignment = .center
    $0.text = "새로운 모임에 참여해 보세요!"
  }
  
  private let moveToMeetingButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "모임 둘러보기")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(stackView)
    [alertImageView, alertLabel, moveToMeetingButton].forEach {
      stackView.addArrangedSubview($0)
    }
    
    stackView.snp.makeConstraints {
      $0.centerY.equalToSuperview().offset(-46)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    alertImageView.snp.makeConstraints {
      $0.size.equalTo(160)
    }
    
    moveToMeetingButton.snp.makeConstraints {
      $0.height.equalTo(46)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  private func bind() {
    moveToMeetingButton.rx.tap
      .subscribe(with: self, onNext: { owner, _ in
        owner.delegate?.didTappedMoveToMeeting()
      })
      .disposed(by: disposeBag)
  }
}
