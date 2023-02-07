//
//  PolicyViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/13.
//

import UIKit

import RxCocoa
import RxSwift

protocol PolicyViewModelType: PolicyViewModel {
  // Input
  var allAgreementButtonTapped: AnyObserver<Void> { get }
  
  // Output
  var checkedButtonListState: Driver<[Bool]> { get }
}

final class PolicyViewModel: PolicyViewModelType {
  
  // Input
  let allAgreementButtonTapped: AnyObserver<Void> // 전체 동의 탭되었을 때
  
  // Output
  let checkedButtonListState: Driver<[Bool]> // 현재 버튼 체크되어있는 상태
  
  private let allAgreementSubject = PublishSubject<Void>()
  private let buttonCheckedRelay = BehaviorRelay<[Bool]>(value: [Bool](repeating: false, count: 5))
  
  private let disposeBag = DisposeBag()
  
  private let policies = [
    "이용약관 및 개인정보취급방침 (필수)",
    "위치 기반 서비스 이용 약관 (필수)",
    "만 14세 이상 확인 (필수)",
    "개인정보 수집 이용 동의 (필수)",
    "마케팅 활용 동의 (선택)"
  ]
  
  /// tableView header cell의 확장여부를 관리합니다.
  private var isHeaderExpandableList = Section.allCases.map { _ in return false }
  
  private var dataSource: DataSource? = nil {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  init() {
    allAgreementButtonTapped = allAgreementSubject.asObserver()
    checkedButtonListState = buttonCheckedRelay.asDriver()
    bind()
  }
}

// MARK: - Rx Progress

extension PolicyViewModel {
  
  func bind() {
    allAgreementSubject
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.applyAllAgreement()
      })
      .disposed(by: disposeBag)
  }
  
  private func applyAllAgreement() {
    let alreadyCheckedAll = buttonCheckedRelay.value.firstIndex(of: false) == nil
    buttonCheckedRelay.accept([Bool](repeating: !alreadyCheckedAll, count: 5))
  }
}

// MARK: - Set Property Methods

extension PolicyViewModel {
  
  // MARK: Configure TableViewCells
  
  /// 셀의 정보를 주입 및 업데이트 합니다. 셀이 reconfigure되거나 reload, init될 때 불려집니다.
  /// - Parameters:
  ///   - cell: UITableViewCell
  ///   - indexPath: indexPath
  ///   - model: Item타입의 모델
  func configure(cell: UITableViewCell, indexPath: IndexPath, model: Item) {
    
    // MARK: body cell 처리
    if let bodyCell = cell as? PolicyBodyTableViewCell {
      // body는 무조건 url이 들어가 있음
      guard let url = model.url else { return }
      bodyCell.configure(with: url)
      return // body cell 적용 후 빠른 리턴
    }
    
    // MARK: header cell 처리
    guard let headerCell = cell as? PolicyHeaderTableViewCell,
          let policy = model.policy else {
      return
    }
    // header cell에 약관 데이터 주입
    headerCell.configure(with: policy, isExpandable: self.isHeaderExpandableList[indexPath.section])
    
    // 셀의 체크박스가 탭되면, viewModel의 check list 업데이트
    headerCell.checkbox.rx.tap
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        var transformedValue = owner.buttonCheckedRelay.value
        transformedValue[indexPath.section] = headerCell.checkbox.isChecked
        owner.buttonCheckedRelay.accept(transformedValue)
      })
      .disposed(by: headerCell.disposeBag) // disposeBag을 cell에게 위임 -> cell 재사용될 시 dispose
    
    // check list가 바뀌면 버튼 ui도 바뀌도록 바인딩 처리 진행
    self.buttonCheckedRelay
      .map { $0[indexPath.section] }
      .bind(to: headerCell.checkbox.rx.isChecked)
      .disposed(by: headerCell.disposeBag) // disposeBag을 cell에게 위임 -> cell 재사용 시 dispose
  }
  
  // MARK: DataSource
  
  /// tableView를 세팅하며, `DiffableDataSource`를 초기화하여 해당 tableView에 데이터를 지닌 셀을 처리합니다.
  /// - Parameter tableView: 보여질 tableView
  func setTableView(_ tableView: UITableView) {
    dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, model in
      let identifier: String
      switch model.type {
      case .header:
        identifier = PolicyHeaderTableViewCell.identifier
      case .body:
        identifier = PolicyBodyTableViewCell.identifier
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      self?.configure(cell: cell, indexPath: indexPath, model: model)
      
      return cell
    }
  }
  
  // MARK: Snapshot
  
  func loadNextSnapshots(for indexPath: IndexPath) {
    guard let dataSource = dataSource,
          let section = Section(rawValue: indexPath.section) else { return }
    
    // 선택한 셀이 body타입이면 단순 리턴
    guard indexPath.row != 1 else { return }
    
    // 기존 dataSource의 snapshot 가져옴
    var snapshot = dataSource.snapshot()
    
    // selected 된 section의 셀의 마지막 정보(identifier)를 가져옴
    // body, header인지 확인하기 위함
    guard let identifier = snapshot.itemIdentifiers(inSection: section).last else { return }
    
    // 마지막이 header값인 경우 == body가 없어 expand 해야하는 경우
    if identifier.type == .header {
      
      // 선택된 cell의 section값을 true로 설정 ==> 나중에 reconfigure하여 화살표의 애니메이션을 정함
      isHeaderExpandableList = isHeaderExpandableList.map { _ in false }
      isHeaderExpandableList[indexPath.section] = true
      
      // 기존에 Expand되었던 다른 body 셀들이 있다면 전부 제거
      let deletableItems = snapshot.itemIdentifiers.filter { $0.type == .body }
      snapshot.deleteItems(deletableItems)
      
      // body cell 추가
      snapshot.appendItems([Item(type: .body, url: URL(string: "https://velog.io/@whitehyun"))], toSection: section)
    }
    // 한번 더 탭되어 collapse 해야하는 경우
    else {
      isHeaderExpandableList[indexPath.section] = false
      snapshot.deleteItems([identifier]) // body cell 제거
    }
    snapshot.reconfigureItems(snapshot.itemIdentifiers) // UI 업데이트
    
    dataSource.apply(snapshot)
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
