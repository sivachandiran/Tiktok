//
//  FeedViewModel.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import UIKit
import RxSwift
import AVFoundation

class FeedViewModel: NSObject, FeedFetchDelegate {
    
    private(set) var currentVideoIndex = 0
    
    //let videoPlayerManager = VideoPlayerManager()
    
    fileprivate var fetcher : FeedFetcher!
    let isLoading = BehaviorSubject<Bool>(value: true)
    let posts = PublishSubject<[Result]>()
    let error = PublishSubject<Error>()

    private var feeds = [Result]()
    
    override init() {
        super.init()
        getPosts(pageNumber: 1, size: 10)
    }
    
    // Setup Audio
    func setAudioMode() {
        do {
            try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch (let err){
            print("setAudioMode error:" + err.localizedDescription)
        }
        
    }
    
    /**
     * First, if videos exist in cache, acquire the cached video
     * Second, if videos don't exist in cache, make a request to firebase and download the video
     */
    func getPosts(pageNumber: Int, size: Int){
        self.isLoading.onNext(true)
        let fetcher = FeedFetcher()
        self.fetcher = fetcher
        self.fetcher.delegate = self
        self.fetcher.fetchFeeds(indexCount: 50)
        
//        PostsRequest.getPostsByPages(pageNumber: pageNumber, size: size, success: { [weak self] data in
//            guard let self = self else { return }
//            //self.isLoading.onNext(false)
//            if let data = data as? QuerySnapshot {
//                for document in data.documents{
//                    // Convert data into Post Entity
//                    var post = Post(dictionary: document.data())
//                    post.id = document.documentID
//                    self.docs.append(post)
//                }
//
//                self.posts.onNext(self.docs)
//                self.isLoading.onNext(false)
//            }
//
//        }, failure: { [weak self] error in
//            guard let self = self else { return }
//            self.isLoading.onNext(false)
//            self.error.onNext(error)
//        })
    }
    
    // TODO: Create a cache manager to store videos in cache
    func feedFetchService(_ service: FeedFetchProtocol, didFetchFeeds feeds: [Result], withError error: Error?) {
        self.isLoading.onNext(false)
        self.feeds = feeds
        self.posts.onNext(self.feeds)
    }
}


