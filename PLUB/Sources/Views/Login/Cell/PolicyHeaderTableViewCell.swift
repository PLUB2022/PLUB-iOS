//
//  PolicyHeaderTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class PolicyHeaderTableViewCell: UITableViewCell {
  
  static let identifier = "\(PolicyHeaderTableViewCell.self)"
  
  var disposeBag = DisposeBag()
  
  private let disclosureIndicator: UIImageView = UIImageView().then {
    $0.image = UIImage(systemName: "chevron.down")
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .deepGray
  }
  
  private let policyLabel: UILabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .body2
    $0.textColor = .deepGray
  }
  
  private let seperatorLineView: UIView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  let checkbox: CheckBoxButton = CheckBoxButton(type: .full)
  
  private let stackView: UIStackView = UIStackView().then {
    $0.spacing = 2
    $0.alignment = .center
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    backgroundColor = .background
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    contentView.addSubview(stackView)
    contentView.addSubview(seperatorLineView)
    [disclosureIndicator, policyLabel, checkbox].forEach {
      stackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    
    seperatorLineView.snp.makeConstraints {
      $0.bottom.horizontalEdges.equalToSuperview()
      $0.height.equalTo(1) // 높이를 1로 설정하여 테이블 구분선을 만듦
    }
    
    stackView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(10)
      $0.bottom.trailing.equalToSuperview().inset(13)
    }
    
    disclosureIndicator.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    checkbox.snp.makeConstraints {
      $0.size.equalTo(24)
    }
  }
  
  /// 화살표 인디케이터에 아래쪽, 위쪽 방향 애니메이션을 적용합니다.
  /// - Parameter flag: Disclosure Indicator의 애니메이션 flag
  private func updateIndicators(flag: Bool) {
    UIView.animate(withDuration: 0.3) {
      let upsideDown = CGAffineTransform(rotationAngle: .pi * 0.9999)
      self.disclosureIndicator.transform = flag ? upsideDown : .identity
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    // 재사용 시 기존의 disposeBag에 있는 Disposables를 Dispose 시킴
    disposeBag = DisposeBag()
  }
  
  func configure(with policy: String, isExpandable: Bool) {
    policyLabel.text = policy
    updateIndicators(flag: isExpandable)
    seperatorLineView.isHidden = isExpandable // 확장될 시 구분선 제거
  }
}
