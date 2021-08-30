//
//  Feed.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import Foundation

struct Feed: Codable {
    
    let count : Int?
    let next : String?
   // let previous : AnyObject?
    var results : [Result]?

    enum CodingKeys: String, CodingKey {
            case count = "count"
            case next = "next"
        // case previous = "previous"
            case results = "results"
    }

    init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            count = try values.decodeIfPresent(Int.self, forKey: .count)
            next = try values.decodeIfPresent(String.self, forKey: .next)
        //    previous = try values.decodeIfPresent(AnyObject.self, forKey: .previous)
            results = try values.decodeIfPresent([Result].self, forKey: .results)
    }

}

