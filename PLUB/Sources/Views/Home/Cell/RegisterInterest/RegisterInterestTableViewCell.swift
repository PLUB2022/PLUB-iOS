//
//  RegisterInterestTableViewCell.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/07.
//

import UIKit

import SnapKit
import Then

struct RegisterInterestTableViewCellModel {
    let imageName: String
    let title: String
    let description: String
    let isExpanded: Bool
}

class RegisterInterestTableViewCell: UITableViewCell {
    
    static let identifier = "RegisterInterestTableViewCell"
    
    var isExpanded: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.containerView.layoutIfNeeded()
            }
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
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 10, weight: .regular)
    $0.textColor = .deepGray
  }
  
  private let indicatorButton = UIButton().then {
    $0.setImage(UIImage(named: "bottomIndicator"), for: .normal)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    interestImageView.image = nil
    titleLabel.text = nil
    descriptionLabel.text = nil
    indicatorButton.setImage(nil, for: .normal)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: isExpanded ? [.topLeft, .topRight] : [.allCorners], radius: 20)
    indicatorButton.setImage(isExpanded ? UIImage(named: "topIndicator") : UIImage(named: "bottomIndicator"), for: .normal)
    if isExpanded {
      containerView.snp.updateConstraints {
        $0.edges.equalToSuperview()
      }
    }
    
    private let interestImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .black
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .gray
    }
    
    private let indicatorButton = UIButton().then {
        $0.setImage(UIImage(named: "Vector 2"), for: .normal)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    [interestImageView, titleLabel, descriptionLabel, indicatorButton].forEach { containerView.addSubview($0) }
    interestImageView.snp.makeConstraints {
      $0.top.left.equalToSuperview().offset(5)
      $0.bottom.equalToSuperview().offset(-5)
      $0.width.equalTo(80)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.roundCorners(corners: isExpanded ? [.topLeft, .topRight] : [.allCorners], radius: 20)
        indicatorButton.setImage(isExpanded ? UIImage(named: "Vector 2-1") : UIImage(named: "Vector 2"), for: .normal)
        if isExpanded {
            containerView.snp.updateConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        else {
            containerView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-5)
            }
        }
    }
    
    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        _ = [interestImageView, titleLabel, descriptionLabel, indicatorButton].map{ containerView.addSubview($0) }
        interestImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(interestImageView.snp.top)
            make.bottom.equalTo(interestImageView.snp.centerY)
            make.left.equalTo(interestImageView.snp.right).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(interestImageView.snp.bottom)
        }
        
        indicatorButton.snp.makeConstraints { make in
            make.centerY.equalTo(interestImageView.snp.centerY)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    public func configureUI(with model: RegisterInterestTableViewCellModel) {
        interestImageView.image = UIImage(named: model.imageName)
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        isExpanded = model.isExpanded
        indicatorButton.setImage(UIImage(named: "Vector 2"), for: .normal)
    }
  }
  
  public func configureUI(with model: RegisterInterestTableViewCellModel) {
    interestImageView.image = UIImage(named: model.imageName)
    titleLabel.text = model.title
    descriptionLabel.text = model.description
    isExpanded = model.isExpanded
    indicatorButton.setImage(UIImage(named: "bottomIndicator"), for: .normal)
  }}

