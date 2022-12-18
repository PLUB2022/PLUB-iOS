//
//  PolicyTableViewCell.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/10.
//

import WebKit
import UIKit

import SnapKit

final class PolicyTableViewCell: UITableViewCell {
  
  static let identifier = "\(PolicyTableViewCell.self)"
  
  private let webView: WKWebView = WKWebView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private func setupLayouts() {
    contentView.addSubview(webView)
  }
  
  private func setupConstraints() {
    webView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(208)
    }
  }
  
  func configure(with url: URL) {
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    webView.stopLoading()
    webView.loadHTMLString("", baseURL: nil)
  }
}
