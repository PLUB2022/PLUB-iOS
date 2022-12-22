//
//  InterestListViewController.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/22.
//

import UIKit
import SnapKit
import Then

class InterestListViewController: BaseViewController {
    
    private let interestListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .systemBackground
    }
    
    override func setupStyles() {
        view.backgroundColor = .systemBackground
    }
    
    override func setupLayouts() {
        
    }
    
    override func setupConstraints() {
        
    }
}
