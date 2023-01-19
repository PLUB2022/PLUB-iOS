//
//  PolicyViewModel.swift
//  PLUB
//
//  Created by 홍승현 on 2022/12/13.
//

import UIKit

import RxCocoa
import RxSwift

final class PolicyViewModel {
  
  private let disposeBag = DisposeBag()
  
  private let policies = [
    "이용약관 및 개인정보취급방침 (필수)",
    "위치 기반 서비스 이용 약관 (필수)",
    "만 14세 이상 확인 (필수)",
    "개인정보 수집 이용 동의 (필수)",
    "마케팅 활용 동의 (선택)"
  ]
  
  private var checkedList = [CheckBoxButton]() {
    didSet {
      // tableView cell의 버튼들이 전부 들어가져있다면
      if checkedList.count == policies.count {
        // 바인딩 처리
        bind()
      }
    }
  }
  
  private var dataSource: DataSource? = nil {
    didSet {
      applyInitialSnapshots()
    }
  }
  
  private let buttonCheckedRelay = BehaviorRelay<[Bool]>(value: [])
}

// MARK: - Rx Progress

extension PolicyViewModel {
  struct Input {
    // 전체 동의 탭되었을 때
    let allAgreementButtonTapped: Observable<Void>
  }
  
  struct Output {
    // 현재 버튼 체크되어있는 상태
    let checkedButtonListState: Driver<[Bool]>
  }
  
  func transform(input: Input) -> Output {
    
    input.allAgreementButtonTapped
      .subscribe(onNext: { [weak self] in
        self?.applyAllAgreement()
      })
      .disposed(by: disposeBag)
    
    return Output(
      checkedButtonListState: buttonCheckedRelay.asDriver()
    )
  }
  
  func bind() {
    let drivers = checkedList.map { $0.rx.isChecked.asDriver() }
    Driver<Bool>.combineLatest(drivers)
      .drive(onNext: { [weak self] _ in
        guard let self = self else { return }
        // 전체 동의 버튼 클릭 시의 isChecked 값이 combineLatest의 값과 연동되어있지 않아서
        // self.checkedList의 isChecked를 accept하도록 구현
        self.buttonCheckedRelay.accept(self.checkedList.map { $0.isChecked })
      })
      .disposed(by: disposeBag)
  }
  
  func applyAllAgreement() {
    // 전체 동의 버튼 클릭되었으므로 모든 체크박스 true 처리
    checkedList.forEach {
      $0.isChecked = true
    }
  }
}

// MARK: - Set Property Methods

extension PolicyViewModel {
  
  // MARK: DataSource
  
  /// tableView를 세팅하며, `DiffableDataSource`를 초기화하여 해당 tableView에 데이터를 지닌 셀을 처리합니다.
  /// - Parameter tableView: 보여질 tableView
  func setTableView(_ tableView: UITableView) {
    dataSource = DataSource(tableView: tableView) { tableView, indexPath, model in
      let identifier: String
      switch model.type {
      case .header:
        identifier = PolicyHeaderTableViewCell.identifier
      case .body:
        identifier = PolicyBodyTableViewCell.identifier
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
      
      if let cellConfigurable = cell as? PolicyConfigurable {
        cellConfigurable.configure(with: model)
      }
      
      if let headerCell = cell as? PolicyHeaderTableViewCell {
        self.checkedList.append(headerCell.checkbox)
      }
      
      return cell
    }
  }
  
  // MARK: Snapshot
  
  func loadNextSnapshots(for indexPath: IndexPath) {
    guard let dataSource = dataSource,
          let section = Section(rawValue: indexPath.section) else { return }
    var snapshot = dataSource.snapshot()
    // selected 된 section의 셀 정보(identifier)를 가져옴
    guard let identifier = snapshot.itemIdentifiers(inSection: section).last else { return }
    
    // body가 없어 expand 해야하는 경우
    if identifier.type == .header {
      snapshot.appendItems([Item(type: .body, url: URL(string: "https://velog.io/@whitehyun"))], toSection: section)
    }
    // body가 이미 존재하지만, 한번 더 탭되어 collapse 해야하는 경우
    else if indexPath.row == 0 {
      snapshot.deleteItems([identifier])
    }
    
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
