
//
//  RegisterInterestTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

protocol RegisterInterestTableViewCellDelegate: AnyObject {
  func didTappedIndicatorButton(cell: RegisterInterestTableViewCell)
}

final class RegisterInterestTableViewCell: UITableViewCell {
  
  static let identifier = "RegisterInterestTableViewCell"
  private let disposeBag = DisposeBag()
  weak var delegate: RegisterInterestTableViewCellDelegate?
  
  var isExpanded: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.containerView.layoutIfNeeded()
      }
    }
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.masksToBounds = true
  }
  
  private let interestImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .bold)
    $0.textColor = .black
  }
  
  private let indicatorButton = ToggleButton(type: .indicator)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    interestImageView.image = nil
    titleLabel.text = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: isExpanded ? [.topLeft, .topRight] : [.allCorners], radius: 10)
    indicatorButton.setImage(isExpanded ? UIImage(named: "topIndicator") : UIImage(named: "bottomIndicator"), for: .normal)
    if isExpanded {
      containerView.snp.updateConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }
    else {
      containerView.snp.updateConstraints {
        $0.bottom.equalToSuperview().offset(-8)
      }
    }
  }
  
  private func configureUI() {
    contentView.backgroundColor = .background
    contentView.addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    [interestImageView, titleLabel, indicatorButton].forEach { containerView.addSubview($0) }
    interestImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(13)
      $0.top.equalToSuperview().offset(16)
      $0.size.equalTo(48)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalTo(interestImageView)
      $0.leading.equalTo(interestImageView.snp.trailing).offset(16)
    }
    
    indicatorButton.snp.makeConstraints {
      $0.centerY.equalTo(interestImageView.snp.centerY)
      $0.trailing.equalToSuperview().offset(-13)
    }
  }
  
  private func bind() {
    indicatorButton.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.delegate?.didTappedIndicatorButton(cell: self)
      })
      .disposed(by: disposeBag)
  }
  
  public func configureUI(with model: RegisterInterestModel) {
    guard let url = URL(string: model.category.icon) else { return }
    interestImageView.kf.setImage(with: url)
    titleLabel.text = model.category.name
    isExpanded = model.isExpanded
  }
}

