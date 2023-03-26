//
//  MeetingCollectionViewCell.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/02.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

enum MeetingSettingType: String, CaseIterable {
  case setting = "내 모임 설정"
  case exit = "모임 나가기"
  case export = "강퇴하기"
  case end = "모임 종료"
}

struct MeetingCellModel {
  let plubbing: MyPlubbing?
  var isDimmed: Bool
  let isHost: Bool
}

protocol MeetingCollectionViewCellDelegate: AnyObject {
  func didTappedSettingButton()
  func didTappedExitButton()
  func didTappedExportButton()
  func didTappedEndButton()
}

final class MeetingCollectionViewCell: UICollectionViewCell {
  static let identifier = "MeetingCollectionViewCell"
  private let disposeBag = DisposeBag()
  private var isHost: Bool?
  
  weak var delegate: MeetingCollectionViewCellDelegate?
  
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  
  private let settingButton = UIButton().then {
    $0.setImage(UIImage(named: "menuWhite"), for: .normal)
  }
  
  private let settingStackView = UIStackView().then {
    $0.layer.cornerRadius = 10
    $0.backgroundColor = .lightGray
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 5, left: .zero, bottom: 5, right: .zero)
  }
  
  private let textStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
    $0.alignment = .center
  }
  
  private let goalView = UIView()
  
  private let goalLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .appFont(family: .nanum, size: 32)
    $0.textAlignment = .center
  }
  
  private let goalBackgroundView = UIView().then {
    $0.backgroundColor = .subMain
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .h2
    $0.textColor = .black
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .caption
    $0.textColor = .black
  }
  
  private let dimmedView = UIView().then {
    $0.backgroundColor = UIColor(hex: 0xFAF9FE, alpha: 0.45)
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
    titleLabel.text = nil
    dateLabel.text = nil
    goalLabel.text = nil
    dimmedView.isHidden = false
    settingStackView.isHidden = true
    settingStackView.subviews.forEach {
      $0.removeFromSuperview()
    }
  }
    
  private func setupLayouts() {
    [imageView, settingButton, settingStackView, textStackView, dimmedView].forEach {
      addSubview($0)
    }
  
    [goalView, titleLabel, dateLabel].forEach {
      textStackView.addArrangedSubview($0)
    }
    
    [goalBackgroundView, goalLabel].forEach {
      goalView.addSubview($0)
    }
  }
    
  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(270)
    }
    
    settingButton.snp.makeConstraints {
      $0.size.equalTo(24)
      $0.top.trailing.equalToSuperview().inset(16)
    }
    
    settingStackView.snp.makeConstraints {
      $0.width.equalTo(89)
      $0.top.equalToSuperview().inset(40)
      $0.trailing.equalToSuperview().inset(14)
    }
    
    textStackView.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview()
    }
    
    goalView.snp.makeConstraints {
      $0.height.equalTo(40)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(33)
    }
    
    dateLabel.snp.makeConstraints {
      $0.height.equalTo(18)
    }
    
    dimmedView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    textStackView.setCustomSpacing(8, after: titleLabel)
    
    goalBackgroundView.snp.makeConstraints {
      $0.width.equalTo(187)
      $0.height.equalTo(19)
      $0.centerX.bottom.equalToSuperview()
    }
    
    goalLabel.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    backgroundColor = .clear
    
    layer.cornerRadius = 30
    layer.borderWidth = 1
    layer.borderColor = UIColor.main.cgColor
  }
  
  private func bind() {
    settingButton
      .rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let isHost = owner.isHost else { return }
        owner.settingButton.isSelected.toggle()
        let isSelected = owner.settingButton.isSelected
        
        owner.settingStackView.isHidden = !isSelected
        if isSelected {
          owner.setupSettingView(isHost: isHost)
        } else {
          owner.settingStackView.subviews.forEach {
            $0.removeFromSuperview()
          }
        }
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(with data: MeetingCellModel) {
    isHost = data.isHost
    guard let plubbing = data.plubbing else { return }
    titleLabel.text = plubbing.name
    goalLabel.text = plubbing.goal
    
    dateLabel.text = plubbing.days
      .map{ $0.fromENGToKOR() }
      .joined(separator: " ,")
    
    dimmedView.isHidden = !data.isDimmed
    
    if let imageURL = plubbing.mainImage, let url = URL(string: imageURL) {
      imageView.kf.setImage(with: url)
    } else {
      imageView.image = nil
    }
    
    imageView.layer.cornerRadius = 30
    imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

    imageView.layer.masksToBounds = true
  }
  
  private func setupSettingView(isHost: Bool) {
    let settingArr = MeetingSettingType.allCases
      .filter { isHost ? true : $0 == .exit }
    
    settingArr.forEach { type in
      let settingSubButton = UIButton().then {
        $0.setTitle(type.rawValue, for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .caption
      }
      settingStackView.addArrangedSubview(settingSubButton)
      
      settingSubButton.snp.makeConstraints {
        $0.height.equalTo(26)
      }
      
      settingSubButton
        .rx.tap
        .asDriver()
        .drive(with: self) { owner, _ in
          switch type {
          case .setting:
            owner.delegate?.didTappedSettingButton()
          case .exit:
            owner.delegate?.didTappedExitButton()
          case .export:
            owner.delegate?.didTappedExportButton()
          case .end:
            owner.delegate?.didTappedEndButton()
          }
        }
        .disposed(by: disposeBag)
    }
  }
}
