//
//  UploadImageResponse.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/25.
//

struct UploadImageResponse: Codable {
  var files: [Files]
}

struct Files: Codable {
  var fileName: String?
  var fileUrl: String?
  
  enum CodingKeys: String, CodingKey {
    case fileName = "filename"
    case fileUrl = "fileUrl"
  }
}
