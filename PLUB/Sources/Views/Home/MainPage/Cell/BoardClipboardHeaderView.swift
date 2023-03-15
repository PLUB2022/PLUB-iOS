//
//  BoardClipboardHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/10.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol BoardClipboardHeaderViewDelegate: AnyObject {
  func didTappedClipboardButton()
}

final class BoardClipboardHeaderView: UICollectionReusableView {
  
  static let identifier = "BoardClipboardHeaderView"
  private let disposeBag = DisposeBag()
  weak var delegate: BoardClipboardHeaderViewDelegate?
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
  }
  
  private let pinImageView = UIImageView().then {
    $0.image = UIImage(named: "pin")
    $0.contentMode = .scaleAspectFill
  }
  
  private let clipboardLabel = UILabel().then {
    $0.text = "클립보드"
    $0.font = .subtitle
    $0.textColor = .black
  }
  
  private let clipboardButton = UIButton().then {
    $0.setImage(UIImage(named: "rightIndicatorGray"), for: .normal)
  }
  
  private let entireStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 12
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 2, left: 13, bottom: 21, right: 13)
  }
  
  private lazy var verticalStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 9
    $0.distribution = .fillEqually
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    entireStackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  private func configureUI() {
    backgroundColor = .white
    layer.masksToBounds = true
    layer.cornerRadius = 10
    [pinImageView, clipboardLabel, clipboardButton].forEach { horizontalStackView.addArrangedSubview($0) }
    pinImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    [horizontalStackView, entireStackView].forEach { addSubview($0) }
    
    clipboardButton.snp.makeConstraints {
      $0.size.equalTo(32)
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(9)
      $0.directionalHorizontalEdges.equalToSuperview().inset(10)
      $0.height.equalTo(32)
    }
    
    entireStackView.snp.makeConstraints {
      $0.top.equalTo(horizontalStackView.snp.bottom)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  private func addElement(which element: [MainPageClipboardViewModel], where at: UIStackView) {
    element.forEach {
      let mainPageClipboardView = MainPageClipboardView()
      mainPageClipboardView.configureUI(with: $0)
      at.addArrangedSubview(mainPageClipboardView)
    }
  }
  
  public func configureUI(with model: [MainPageClipboardViewModel]) {
    guard !model.isEmpty else { return }
    let mainpageClipboardType = MainPageClipboardType.getMainPageClipboardType(with: model)
    
    switch mainpageClipboardType {
    case .moreThanThree:
      var model = Array(model[0..<3])
      guard let firstModel = model.first else { return }
      model.remove(at: 0)
      let mainPageClipboardView = MainPageClipboardView()
      mainPageClipboardView.configureUI(with: firstModel)
      
      [mainPageClipboardView, verticalStackView].forEach { entireStackView.addArrangedSubview($0) }
      addElement(which: model, where: verticalStackView)
    default:
      addElement(which: model, where: entireStackView)
    }
  }
  
  private func bind() {
    clipboardButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedClipboardButton()
      }
      .disposed(by: disposeBag)
  }
}
