//
//  IntroduceCategoryViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/02.
//

import UIKit

import SnapKit
import Then

final class IntroduceCategoryViewController: BaseViewController {
  
  private let model: SelectedCategoryCollectionViewCellModel
  
  private let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = true
    $0.showsHorizontalScrollIndicator = false
    $0.alwaysBounceVertical = true
  }
  
  private let introduceTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .h3
    $0.text = "책 읽고 얘기해요!"
    $0.backgroundColor = .orange
  }
  
  private let introduceTypeStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .leading
    $0.distribution = .fillEqually
  }
  
  private let meetingTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 18)
    $0.text = "요란한 한줄"
  }
  
  private let meetingDateLabel = UILabel().then {
    $0.textColor = .deepGray
    $0.font = .systemFont(ofSize: 12)
    $0.text = "화수금 오후 1시"
  }
  
  private let categoryInfoListView = CategoryInfoListView(categoryInfoListViewType: .horizontal)
  
  private let meetingRecommendedLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 32)
    $0.textColor = .main
    $0.text = "“스트레칭은 20분 이상”"
    $0.sizeToFit()
  }
  
  private let meetingImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.image = UIImage(named: "Rectangle 415")
  }
  
  private let meetingIntroduceLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
    $0.text = "[ 요란한 한줄 ] 모임은요...!"
  }
  
  private let meetingDescriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .justified
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.text = """
    유럽의 전통 춤 중 하나. 기원은 이탈리아. 나중에 프랑스가 이탈리아에서 들여와서 프랑스라고 알고 있는 사람들이 많으며, 유명세 때문에 러시아 춤이라고 알고 있는 사람도 있다.
    어원은 라틴어의 '춤추다(ballare)'. 여기서 이탈리아어 '춤(ballo, 발로)'에서 또 변형되어 오늘날의 발레가 되었다. 15세기 이탈리아에서 시작되었는데, 기존의 전통 춤을 발전시킨 춤이며, 현대의 우아한 발레와 달리 남자의 전유물이었다고 한다. 여성은 발레리나, 남성은 발레리노라고 한다.
    로마자 표기가. Ballet라서 발렛 내지는 발레트라고 발음해야 한다는 사람도 소수 있는데, 이 단어가 끝의 자음은 발음하지 않는 프랑스어에서 비롯된 것이라 발레라고 발음하는
    15세기에 이탈리아에서 시작된 발레는 원래 귀족사회에서 추던 춤이었는데, 16세기경 프랑스로 시집간 카트린 드 메디시스 왕비에 의해 프랑스에 전래되었다고 한다. 여기서 발레의 발전이 시작된다. 루이 14세는 여러 문화에 대해 관심이 많았는데, 그 중에서도 발레에 열광했다고 한다. 직접 춤을 배우고 공연의 주역까지 맡을 만큼 열정이 대단했다고 하며, 1661년 왕립 발레 아카데미도 설립하기도 했다.[3] 그리고. 같은 해에 쟝 바티스트 륄리의 음악과 결합된 코미디 발레가 나왔다.
    """
  }
  
  init(model: SelectedCategoryCollectionViewCellModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    [introduceTitleLabel, introduceTypeStackView, meetingTitleLabel, meetingDateLabel, categoryInfoListView, meetingRecommendedLabel, meetingImageView, meetingIntroduceLabel, meetingDescriptionLabel].forEach { scrollView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints {
      $0.edges.width.equalToSuperview() // 타이틀에 대한 너비까지 잡아줌으로써 Vertical Enabled한 UI를 구성
    }
    
    introduceTitleLabel.snp.makeConstraints {
      $0.top.centerX.equalToSuperview()
      $0.right.equalToSuperview().offset(-20)
      $0.left.equalToSuperview().offset(20)
    }
    
    introduceTypeStackView.snp.makeConstraints {
      $0.top.equalTo(introduceTitleLabel.snp.bottom)
      $0.left.right.equalTo(introduceTitleLabel)
    }
    
    meetingTitleLabel.snp.makeConstraints {
      $0.top.equalTo(introduceTypeStackView.snp.bottom)
      $0.left.equalTo(introduceTypeStackView)
    }
    
    meetingDateLabel.snp.makeConstraints {
      $0.left.equalTo(meetingTitleLabel.snp.right)
      $0.bottom.equalTo(meetingTitleLabel)
    }
    
    categoryInfoListView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(meetingDateLabel.snp.bottom).offset(20)
    }
    
    meetingRecommendedLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(categoryInfoListView).offset(20)
    }
    
    meetingImageView.snp.makeConstraints {
      $0.left.right.equalTo(introduceTitleLabel)
      $0.top.equalTo(meetingRecommendedLabel.snp.bottom).offset(10)
      $0.height.equalTo(246)
    }
    
    meetingIntroduceLabel.snp.makeConstraints {
      $0.left.right.equalTo(introduceTitleLabel)
      $0.top.equalTo(meetingImageView.snp.bottom).offset(10)
      $0.height.equalTo(21)
    }
    
    meetingDescriptionLabel.snp.makeConstraints {
      $0.left.right.equalTo(introduceTitleLabel)
      $0.top.equalTo(meetingIntroduceLabel.snp.bottom).offset(10)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .background
    categoryInfoListView.configureUI(with: .init(location: "서울 서초구", peopleCount: 10, when: "매주 금요일 | 오후 5시 30분"))
    categoryInfoListView.backgroundColor = .black
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "back"),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      image: UIImage(named: "checkBookmark"),
      style: .plain,
      target: self,
      action: #selector(didTappedComponentButton)
    )
  }
  
  @objc private func didTappedBackButton() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc private func didTappedComponentButton() {
    
  }
}
