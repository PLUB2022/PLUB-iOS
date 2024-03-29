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
  func didTappedBoardClipboardHeaderView()
}

final class BoardClipboardHeaderView: UICollectionReusableView {
  
  static let identifier = "BoardClipboardHeaderView"
  private let disposeBag = DisposeBag()
  weak var delegate: BoardClipboardHeaderViewDelegate?
  
  private let contentView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
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
  
  private let clipboardImageView = UIImageView().then {
    $0.image = UIImage(named: "rightIndicatorGray")
    $0.contentMode = .scaleAspectFill
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
  
  private let tapGesture = UITapGestureRecognizer(target: BoardClipboardHeaderView.self, action: nil)
  
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
    verticalStackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  private func bind() {
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedBoardClipboardHeaderView()
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    backgroundColor = .background
    contentView.addGestureRecognizer(tapGesture)
    
    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview().inset(8)
    }
    
    [pinImageView, clipboardLabel, clipboardImageView].forEach { horizontalStackView.addArrangedSubview($0) }
    pinImageView.snp.makeConstraints {
      $0.size.equalTo(24)
    }
    
    [horizontalStackView, entireStackView].forEach { contentView.addSubview($0) }
    
    clipboardImageView.snp.makeConstraints {
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
  
  func configureUI(with model: [MainPageClipboardViewModel]) {
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
}
