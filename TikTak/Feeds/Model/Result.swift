//
//  Result.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import Foundation

struct Result : Codable {
    
    let creator : Int?
    let creatorIsVerified : Bool?
    var creatorPic : String?
    let creatorUsername : String?
    let descriptionField : String?
    let downloads : Int?
    var file : String?
  //  let hashtags : [AnyObject]?
    let id : Int!
    var isFollowing : Bool?
    var isLiked : Bool?
    var music : Int?
    let musicText : String?
    var numComments : Int?
    var numLikes : Int?
    var numViews : Int?
    var poster : String?
    var shares : Int?
    var url : URL?

    enum CodingKeys: String, CodingKey {
            case creator = "creator"
            case creatorIsVerified = "creator_is_verified"
            case creatorPic = "creator_pic"
            case creatorUsername = "creator_username"
            case descriptionField = "description"
            case downloads = "downloads"
            case file = "file"
           // case hashtags = "hashtags"
            case id = "id"
            case isFollowing = "is_following"
            case isLiked = "is_liked"
            case music = "music"
            case musicText = "music_text"
            case numComments = "num_comments"
            case numLikes = "num_likes"
            case numViews = "num_views"
            case poster = "poster"
            case shares = "shares"
        case url = "url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        creator = try values.decodeIfPresent(Int.self, forKey: .creator)
        creatorIsVerified = try values.decodeIfPresent(Bool.self, forKey: .creatorIsVerified)
        creatorPic = try values.decodeIfPresent(String.self, forKey: .creatorPic)
        if(creatorPic == nil) {
            creatorPic = ""
        }
        creatorUsername = try values.decodeIfPresent(String.self, forKey: .creatorUsername)
        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
        downloads = try values.decodeIfPresent(Int.self, forKey: .downloads)
        file = try values.decodeIfPresent(String.self, forKey: .file)
       // hashtags = try values.decodeIfPresent([AnyObject].self, forKey: .hashtags)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        isFollowing = try values.decodeIfPresent(Bool.self, forKey: .isFollowing)
        isLiked = try values.decodeIfPresent(Bool.self, forKey: .isLiked)
        music = try values.decodeIfPresent(Int.self, forKey: .music)
        if(music == nil) {
            music = 0
        }
        musicText = try values.decodeIfPresent(String.self, forKey: .musicText)
        numComments = try values.decodeIfPresent(Int.self, forKey: .numComments)
        numLikes = try values.decodeIfPresent(Int.self, forKey: .numLikes)
        numViews = try values.decodeIfPresent(Int.self, forKey: .numViews)
        poster = try values.decodeIfPresent(String.self, forKey: .poster)
        if(poster == nil) {
            poster = ""
        }
        shares = try values.decodeIfPresent(Int.self, forKey: .shares)
        url = try values.decodeIfPresent(URL.self, forKey: .url)
    }

}

