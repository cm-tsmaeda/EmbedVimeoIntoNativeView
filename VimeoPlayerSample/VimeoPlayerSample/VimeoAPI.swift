//
//  VimeoAPI.swift
//  VimeoPlayerSample
//  
//  Created by maeda.tasuku on 2021/09/15
//  
//

import Foundation

struct VimeoGetVideoInfoRequest {
    let baseUrlStr: String = "https://vimeo.com/api/oembed.json?responsive=true&url="
    let videoId: String
    
    var url: URL? {
        let videoUrl = "https://vimeo.com/\(videoId)"
        guard let encoded = videoUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        return URL(string: baseUrlStr + encoded)
    }
}

/// 動画情報
struct VimeoVideoInfo: Codable {
    
    let videoId: Int
    let width: Int
    let height: Int
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case width
        case height
    }
}

enum VimeoError: Error {
    case fetch
    case other(Error)
    
    static func map(_ error: Error) -> VimeoError {
        if let vimeoError = error as? VimeoError {
            return vimeoError
        }
        return .other(error)
    }
}
