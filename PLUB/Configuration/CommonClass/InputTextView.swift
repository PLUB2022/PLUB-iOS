//
//  InputTextView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import UIKit
import RxSwift

import SnapKit

final class InputTextView: UIView {
  
  // MARK: - Property
  private let disposeBag = DisposeBag()
  
  private let placeHolder: String
  private let totalCharacterLimit: Int?
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let titleView = UIView()
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
  }
  
  private let questionButton = UIButton().then {
    $0.setImage(UIImage(named: "questionButton"), for: .normal)
  }
  
  private let textView = UITextView().then {
    $0.textColor = .deepGray
    $0.textContainerInset = UIEdgeInsets(
      top: 11,
      left: 8,
      bottom: 11,
      right: 8
    )
    $0.font = .body2
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.isScrollEnabled = false
  }
  
  private let countTextLabel = UILabel().then {
    $0.font = .overLine
    $0.textAlignment = .right
  }
  
  init(
    title: String,
    placeHolder: String,
    options: InputViewOptions = [],
    totalCharacterLimit: Int? = 150
  ) {
    self.placeHolder = placeHolder
    self.totalCharacterLimit = options.contains(.questionMark) ? totalCharacterLimit : nil
    
    super.init(frame: .zero)
    
    titleLabel.text = title
    textView.text = placeHolder
    setupLayouts(options: options)
    setupConstraints(options: options)
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts(options: InputViewOptions) {
    addSubview(stackView)
    
    let stackViewSubviews = [
      titleView,
      textView,
      options.contains(.textCount) ? countTextLabel : nil
    ].compactMap { $0 }
    
    stackViewSubviews.forEach {
      stackView.addArrangedSubview($0)
    }
    
    let titleStackViewSubviews = [
      titleLabel,
      options.contains(.questionMark) ? questionButton : nil
    ].compactMap { $0 }
    
    titleStackViewSubviews.forEach {
      titleView.addSubview($0)
    }
  }
  
  private func setupConstraints(options: InputViewOptions) {
    stackView.snp.makeConstraints{
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    titleView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    if options.contains(.questionMark) {
      questionButton.snp.makeConstraints {
        $0.size.equalTo(12)
        $0.centerY.equalTo(titleLabel.snp.centerY)
        $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
      }
    }
    
    textView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    if options.contains(.textCount) {
      countTextLabel.snp.makeConstraints {
        $0.height.equalTo(12)
      }
      stackView.setCustomSpacing(4, after: textView)
    }
  }
  
  private func setupStyles() {
    updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
  }
  
  private func bind() {
    textView.rx.didBeginEditing
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if self.textView.text == self.placeHolder &&
           self.textView.textColor == .deepGray {
          self.textView.text = ""
          self.textView.textColor = .black
        }
      }
    ).disposed(by: disposeBag)
    
    textView.rx.didEndEditing
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
          self.textView.textColor == .black {
          updateWrittenCharactersLabel(count: 0, pointColor: .mediumGray)
          self.textView.text = self.placeHolder
          self.textView.textColor = .deepGray
        }
        
        self.updateTextViewHeightAutomatically()
      }
    ).disposed(by: disposeBag)
  
    textView.rx.text
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        self.updateTextViewHeightAutomatically()
        
        guard $0 != self.placeHolder, // placeHolder
              let text = $0 else { return }
        
        let color: UIColor = self.textView.text.count == 0 ? .mediumGray : .black
        self.updateWrittenCharactersLabel(count: self.textView.text.count, pointColor: color)
        
        guard let maxTextCount = self.totalCharacterLimit else { return } // 글자수 무제한
        
        guard text.count > maxTextCount else { return }
        let index = text.index(text.startIndex, offsetBy: maxTextCount)
        self.textView.text = String(text[..<index]) // 글자수 제한
      }
    ).disposed(by: disposeBag)
  }
}

// MARK: - Function

extension InputTextView {
  private func updateTextViewHeightAutomatically() {
    let size = CGSize(
      width: textView.frame.width,
      height: .infinity
    )
    let estimatedSize = textView.sizeThatFits(size)
    
    textView.snp.updateConstraints {
      $0.height.equalTo(estimatedSize.height)
    }
  }
  
  private func updateWrittenCharactersLabel(
    count: Int,
    pointColor: UIColor
  ) {
    let writtenCharacters = NSAttributedString(
      string: "\(count)",
      attributes: [.foregroundColor: pointColor]
    )
    
    let totalCharacters = NSAttributedString(
      string: "/\(totalCharacterLimit ?? 0)",
      attributes: [.foregroundColor: UIColor.deepGray]
    )
    
    countTextLabel.attributedText = NSMutableAttributedString(attributedString: writtenCharacters).then {
      $0.append(totalCharacters)
    }
  }
}

struct InputViewOptions: OptionSet {
  let rawValue: UInt
  
  static let textCount = InputViewOptions(rawValue: 1 << 0) // 글자수 세기
  static let questionMark = InputViewOptions(rawValue: 1 << 1) // 물음표 버튼
}
