//
//  InterestListViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit
import SnapKit
import Then

enum InterestListType {
    case Chart
    case Grid
}

class InterestListViewController: BaseViewController {
    
    private let viewModel: InterestListViewModelType
    
    private var interestListType: InterestListType = .Chart
    
    private lazy var interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then({
        $0.scrollDirection = .vertical
        $0.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    })).then {
        $0.backgroundColor = .systemBackground
    }.then {
        $0.register(InterestListGridCollectionViewCell.self, forCellWithReuseIdentifier: InterestListGridCollectionViewCell.identifier)
        $0.register(InterestListChartCollectionViewCell.self, forCellWithReuseIdentifier: InterestListChartCollectionViewCell.identifier)
        $0.register(InterestListFilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: InterestListFilterHeaderView.identifier)
    }
    
    private lazy var interestListNavigationBar = InterestListNavigationBar().then {
        $0.configureUI(with: title ?? "")
    }
    
    init(viewModel: InterestListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupStyles() {
        view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
        
        interestListNavigationBar.delegate = self
        interestListCollectionView.delegate = self
        interestListCollectionView.dataSource = self
    }
    
    override func setupLayouts() {
        _ = [interestListNavigationBar, interestListCollectionView].map{ view.addSubview($0) }
    }
    
    override func setupConstraints() {
        interestListNavigationBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }
        
        interestListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(interestListNavigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension InterestListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch interestListType {
            case .Chart:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestListChartCollectionViewCell.identifier, for: indexPath) as? InterestListChartCollectionViewCell ?? InterestListChartCollectionViewCell()
                cell.configureUI(with: "")
                return cell
            case .Grid:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InterestListGridCollectionViewCell.identifier, for: indexPath) as? InterestListGridCollectionViewCell ?? InterestListGridCollectionViewCell()
                cell.configureUI(with: "")
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == self.interestListCollectionView && kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: InterestListFilterHeaderView.identifier, for: indexPath) as? InterestListFilterHeaderView ?? InterestListFilterHeaderView()
            header.delegate = self
            return header
        }
        else { return UICollectionReusableView() }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch interestListType {
            case .Chart:
            return CGSize(width: collectionView.frame.width - 10 - 10, height: collectionView.frame.height / 4 - 10)
            case .Grid:
            return CGSize(width: collectionView.frame.width / 2 - 10 - 10, height: collectionView.frame.height / 3 - 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension InterestListViewController: InterestListNavigationBarDelegate {
    func didTappedBackButton() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTappedSearchButton() {
        print("tapped search")
    }
    
    
}

extension InterestListViewController: InterestListFilterHeaderViewDelegate {
    func didTappedInterestListFilterButton() {
        
    }
    
    func didTappedInterestListChartButton() {
        self.interestListType = .Chart
        self.interestListCollectionView.reloadSections([0])
    }
    
    func didTappedInterestListGridButton() {
        self.interestListType = .Grid
        self.interestListCollectionView.reloadSections([0])
    }
    
    
}
