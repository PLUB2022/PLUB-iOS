//
//  MeetingIntroduceView.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/18.
//

import UIKit

import SnapKit
import Then

class MeetingIntroduceView: UIView {
  
  private let meetingIntroduceLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18)
    $0.textColor = .black
    $0.text = "[ 요란한 한줄 ] 모임은요...!"
    $0.sizeToFit()
  }
  
  private let meetingDescriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14)
    $0.textAlignment = .justified
    $0.textColor = .black
    $0.numberOfLines = 0
    $0.sizeToFit()
    $0.text = """
    유럽의 전통 춤 중 하나. 기원은 이탈리아. 나중에 프랑스가 이탈리아에서 들여와서 프랑스라고 알고 있는 사람들이 많으며, 유명세 때문에 러시아 춤이라고 알고 있는 사람도 있다.
    어원은 라틴어의 '춤추다(ballare)'. 여기서 이탈리아어 '춤(ballo, 발로)'에서 또 변형되어 오늘날의 발레가 되었다. 15세기 이탈리아에서 시작되었는데, 기존의 전통 춤을 발전시킨 춤이며, 현대의 우아한 발레와 달리 남자의 전유물이었다고 한다. 여성은 발레리나, 남성은 발레리노라고 한다.
    로마자 표기가. Ballet라서 발렛 내지는 발레트라고 발음해야 한다는 사람도 소수 있는데, 이 단어가 끝의 자음은 발음하지 않는 프랑스어에서 비롯된 것이라 발레라고 발음하는
    15세기에 이탈리아에서 시작된 발레는 원래 귀족사회에서 추던 춤이었는데, 16세기경 프랑스로 시집간 카트린 드 메디시스 왕비에 의해 프랑스에 전래되었다고 한다. 여기서 발레의 발전이 시작된다. 루이 14세는 여러 문화에 대해 관심이 많았는데, 그 중에서도 발레에 열광했다고 한다. 직접 춤을 배우고 공연의 주역까지 맡을 만큼 열정이 대단했다고 하며, 1661년 왕립 발레 아카데미도 설립하기도 했다.[3] 그리고. 같은 해에 쟝 바티스트 륄리의 음악과 결합된 코미디 발레가 나왔다.
    """
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [meetingIntroduceLabel, meetingDescriptionLabel].forEach { addSubview($0) }
    meetingIntroduceLabel.snp.makeConstraints { make in
      make.top.left.equalToSuperview()
    }
    
    meetingDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(meetingIntroduceLabel.snp.bottom).offset(16)
      make.left.right.bottom.equalToSuperview()
      make.width.equalTo(Device.width)
    }
  }
}
