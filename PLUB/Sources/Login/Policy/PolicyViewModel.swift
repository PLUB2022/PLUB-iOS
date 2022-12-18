//
//  PolicyViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/13.
//

import UIKit

final class PolicyViewModel {
  
  private let policies = [
    "이용약관 및 개인정보취급방침 (필수)",
    "위치 기반 서비스 이용 약관 (필수)",
    "만 14세 이상 확인 (필수)",
    "개인정보 수집 이용 동의 (필수)",
    "마케팅 활용 동의 (선택)"
  ]
  
  private var dataSource: DataSource? = nil {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  private var snapshot = Snapshot()
}

// MARK: - Set Property Methods

extension PolicyViewModel {
  
  /// tableView를 세팅하며, `DiffableDataSource`를 초기화하여 해당 tableView에 데이터를 지닌 셀을 처리합니다.
  /// - Parameter tableView: 보여질 tableView
  func setTableView(_ tableView: UITableView) {
    self.dataSource = DataSource(tableView: tableView) { tableView, indexPath, model in
      
      // == header cell ==
      let identifier: String
      switch model.type {
      case .header:
        identifier = PolicyHeaderTableViewCell.identifier
      case .body:
        identifier = PolicyTableViewCell.identifier
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      
      if let cellConfigurable = cell as? PolicyConfigurable {
        cellConfigurable.configure(with: model)
      }
      
      return cell
    }
  }
  
  /// 초기 Snapshot을 설정합니다. DataSource가 초기화될 시 해당 메서드가 실행됩니다.
  /// 직접 이 메서드를 실행할 필요는 없습니다.
  private func applyInitialSnapshots() {
    var snapshot = Snapshot()
    snapshot.appendSections(Section.allCases)
    for (section, policy) in zip(Section.allCases, policies) {
      snapshot.appendItems([Item(type: .header, policy: policy)], toSection: section)
    }
    dataSource?.apply(snapshot)
  }
}

// MARK: - Diffable Models & Types

extension PolicyViewModel {
  
  typealias DataSource = UITableViewDiffableDataSource<Section, Item>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
  
  enum Section: Int, CaseIterable {
    /// 이용약관 및 개인정보 취급 방침
    case termsOfService
    /// 위치 기반 서비스 이용 약관
    case locationBasedService
    /// 만 14세 이상 확인
    case termsAndConditionsForAges
    /// 개인정보 수집 이용 동의
    case privacyPolicy
    /// 마케팅 활용 동의
    case marketing
  }
  
  enum CellType {
    case header
    case body
  }
  
  struct Item: Hashable {
    let type: CellType
    let url: URL?
    let policy: String?
    
    init(type: CellType, url: URL? = nil, policy: String? = nil) {
      self.type = type
      self.url = url
      self.policy = policy
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(identifier)
    }
    
    private let identifier = UUID()
  }
}
