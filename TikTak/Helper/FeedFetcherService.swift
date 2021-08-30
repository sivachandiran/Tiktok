//
//  FeedFetcherService.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

protocol FeedFetchDelegate: class {
    func feedFetchService(_ service: FeedFetchProtocol, didFetchFeeds feeds: [Result], withError error: Error?)
}

protocol FeedFetchProtocol: class {
    var delegate: FeedFetchDelegate? { get set }
    func fetchFeeds(indexCount : Int)
    func fetchFeeds(feed : [Result])
}

class FeedFetcher: FeedFetchProtocol {
    fileprivate let networking: ConnectionProtocol.Type
    weak var delegate: FeedFetchDelegate?
    
    init(networking: ConnectionProtocol.Type = Connection.self) {
        self.networking = networking
    }
    
    func fetchFeeds(feed : [Result]) {
        self.delegate?.feedFetchService(self, didFetchFeeds: feed, withError: nil)

    }
    func fetchFeeds(indexCount : Int) {
        let stringURL = "\("https://api.lolipop.live/api/v1/videos/?type=TRENDING&limit=")\(indexCount)"
        APIManager.shared.fetchAPIDetails(url: stringURL, Stringmethod: "GET", params: Dictionary<String, AnyObject>()) { (response, error) in
            self.fetchFeedSuccess(withData: response as! Data)

        }
    }

    fileprivate func fetchFeedFailed(withError error: Error) {
//        self.delegate?.feedFetchService(self, didFetchFeeds: [], withError: error)
    }
    
    fileprivate func fetchFeedSuccess(withData data: Data) {
        let jsonDecoder = JSONDecoder()
        let responseModel = try? jsonDecoder.decode(Feed.self, from: data )
        self.delegate?.feedFetchService(self, didFetchFeeds: (responseModel?.results!)!, withError: nil)
    }
   
}


