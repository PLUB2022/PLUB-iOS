//
//  PolicyBodyTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import WebKit
import UIKit

import SnapKit

final class PolicyBodyTableViewCell: UITableViewCell {
  
  static let identifier = "\(PolicyBodyTableViewCell.self)"
  
  private let webView: WKWebView = WKWebView()
  
  private let seperatorLineView: UIView = UIView().then {
    $0.backgroundColor = .lightGray
    $0.isHidden = true
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
    contentView.addSubview(webView)
    contentView.addSubview(seperatorLineView)
  }
  
  private func setupConstraints() {
    webView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(26) // 24(size) + 2(spacing)
      make.trailing.equalToSuperview().inset(39) // 13(trailing) + 24(size) + 2(spacing)
      make.verticalEdges.equalToSuperview().inset(4)
      make.height.equalTo(208)
    }
    
    seperatorLineView.snp.makeConstraints { make in
      make.bottom.horizontalEdges.equalToSuperview()
      make.height.equalTo(1) // 높이를 1로 설정하여 테이블 구분선을 만듦
    }
  }
  
  func configure(with url: URL) {
    let request = URLRequest(url: url)
    webView.load(request)
    seperatorLineView.isHidden = false
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
}
