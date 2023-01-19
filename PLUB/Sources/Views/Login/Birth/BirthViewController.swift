//
//  BirthViewController.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/22.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class BirthViewController: BaseViewController {
  
  // MARK: - Property
  
  /// 성별과 생년월일 전체를 감싸는 `StackView`
  private let wholeStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 48
  }
  
  // MARK: Sex Distinction
  
  private let sexStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let sexLabel: UILabel = UILabel().then {
    $0.text = "성별"
    $0.font = .subtitle
  }
  
  private let buttonStackView: UIStackView = UIStackView().then {
    $0.spacing = 16
    $0.alignment = .center
    $0.distribution = .fillEqually
  }
  
  private let maleButton: UIButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "남성")
  }
  
  private let femaleButton: UIButton =  UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.list(label: "여성")
  }
  
  // MARK: Birth
  
  private let birthStackView: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let birthLabel: UILabel = UILabel().then {
    $0.text = "생년월일"
    $0.font = .subtitle
  }
  
  private let birthSettingControl = CalendarControl()
  
  // MARK: - Configuration
  
  override func setupLayouts() {
    super.setupLayouts()
    
    // views
    view.addSubview(wholeStackView)
    
    [sexStackView, birthStackView].forEach {
      wholeStackView.addArrangedSubview($0)
    }
    
    // Sex Distinction part
    [sexLabel, buttonStackView].forEach {
      sexStackView.addArrangedSubview($0)
    }
    
    [maleButton, femaleButton].forEach {
      buttonStackView.addArrangedSubview($0)
    }
    
    // Birth part
    [birthLabel, birthSettingControl].forEach {
      birthStackView.addArrangedSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    wholeStackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(24)
      $0.top.equalToSuperview()
    }
    
    [maleButton, femaleButton].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(46)
      }
    }
    
    birthSettingControl.snp.makeConstraints {
      $0.height.equalTo(48)
    }
  }
  
  override func bind() {
    super.bind()
    
    maleButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.maleButton.isSelected.toggle()
      })
      .disposed(by: disposeBag)
    
    femaleButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.femaleButton.isSelected.toggle()
      })
      .disposed(by: disposeBag)
    
    birthSettingControl.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        let vc = DateBottomSheetViewController(type: .date, buttonTitle: "생일 입력 완료")
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = owner
        owner.parent?.present(vc, animated: false)
      })
      .disposed(by: disposeBag)
  }
}

extension BirthViewController: DateBottomSheetDelegate {
  func selectDate(date: Date) {
    birthSettingControl.date = date
    birthSettingControl.isSelected = true
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct BirthViewControllerPreview: PreviewProvider {
  static var previews: some View {
    BirthViewController().toPreview()
  }
}
#endif
