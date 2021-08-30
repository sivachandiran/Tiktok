//
//  VideoPlayerView.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import UIKit
import Foundation
import AVFoundation
import Alamofire

class VideoPlayerView: UIView {
    
    // MARK: - Variables
    var videoURL: URL?
    var originalURL: URL?
    var asset: AVURLAsset?
    var playerItem: AVPlayerItem?
    var playerLayer: AVPlayerLayer!
    var playerLooper: AVPlayerLooper! // should be defined in class
    var player: AVQueuePlayer?
    var observer: NSKeyValueObservation?
    
    private var session: URLSession?
    private var loadingRequests = [AVAssetResourceLoadingRequest]()
    private var task: URLSessionDataTask?
    private var infoResponse: URLResponse?
    private var cancelLoadingQueue: DispatchQueue?
    private var videoData: Data?
    private var fileExtension: String?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
    
    func setupView(){
        let operationQueue = OperationQueue()
        operationQueue.name = "com.VideoPlayer.URLSeesion"
        operationQueue.maxConcurrentOperationCount = 1
        session = URLSession.init(configuration: .default, delegate: self, delegateQueue: operationQueue)
        cancelLoadingQueue = DispatchQueue.init(label: "com.cancelLoadingQueue")
        videoData = Data()
    }
    
    func configure(url: URL?, feed: Result){
        // If Height is larger than width, change the aspect ratio of the video
        guard let url = url else {
            print("URL Error from Tableview Cell")
            return
        }        
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerItem = AVPlayerItem(url: url)
        playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem!)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = self.layer.bounds
        playerLayer.cornerRadius = 12.0
        self.layer.addSublayer(playerLayer)
    }
    
    /// Clear all remote or local request
    func cancelAllLoadingRequest(){
        removeObserver()
        
        videoURL = nil
        originalURL = nil
        asset = nil
        playerItem = nil
        playerLayer.player = nil
        playerLooper = nil
        
        cancelLoadingQueue?.async { [weak self] in
            self?.session?.invalidateAndCancel()
            self?.session = nil
            
            self?.asset?.cancelLoading()
            self?.task?.cancel()
            self?.task = nil
            self?.videoData = nil
            
            self?.loadingRequests.forEach { $0.finishLoading() }
            self?.loadingRequests.removeAll()
        }

    }
    
    
    func replay(){
        self.player?.seek(to: .zero)
        play()
    }
    
    func play() {
        self.player?.play()
    }
    
    func pause(){
        self.player?.pause()
    }
    
}
// MARK: - KVO
extension VideoPlayerView {
    func removeObserver() {
        if let observer = observer {
            observer.invalidate()
        }
    }
    
    fileprivate func addObserverToPlayerItem() {
        // Register as an observer of the player item's status property
        self.observer = self.playerItem!.observe(\.status, options: [.initial, .new], changeHandler: { item, _ in
            let status = item.status
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("Status: readyToPlay")
            case .failed:
                // Player item failed. See error.
                print("Status: failed Error: " + item.error!.localizedDescription )
            case .unknown:
                // Player item is not yet ready.bn m
                print("Status: unknown")
            @unknown default:
                fatalError("Status is not yet ready to present")
            }
        })
    }
}

// MARK: - URL Session Delegate
extension VideoPlayerView: URLSessionTaskDelegate, URLSessionDataDelegate {
    // Get Responses From URL Request
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.infoResponse = response
        self.processLoadingRequest()
        completionHandler(.allow)
    }
    
    // Receive Data From Responses and Download
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.videoData?.append(data)
        self.processLoadingRequest()
    }
    
    // Responses Download Completed
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("AVURLAsset Download Data Error: " + error.localizedDescription)
        } else {
            VideoCacheManager.shared.storeDataToCache(data: self.videoData, key: self.originalURL!.absoluteString, fileExtension: self.fileExtension)
        }
    }
    
    private func processLoadingRequest(){
        var finishedRequests = Set<AVAssetResourceLoadingRequest>()
        self.loadingRequests.forEach {
            var request = $0
            if self.isInfo(request: request), let response = self.infoResponse {
                self.fillInfoRequest(request: &request, response: response)
            }
            if let dataRequest = request.dataRequest, self.checkAndRespond(forRequest: dataRequest) {
                finishedRequests.insert(request)
                request.finishLoading()
            }
        }
        self.loadingRequests = self.loadingRequests.filter { !finishedRequests.contains($0) }
    }
    
    private func fillInfoRequest(request: inout AVAssetResourceLoadingRequest, response: URLResponse) {
        request.contentInformationRequest?.isByteRangeAccessSupported = true
        request.contentInformationRequest?.contentType = response.mimeType
        request.contentInformationRequest?.contentLength = response.expectedContentLength
    }
    
    private func isInfo(request: AVAssetResourceLoadingRequest) -> Bool {
         return request.contentInformationRequest != nil
     }
    
    private func checkAndRespond(forRequest dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        guard let videoData = videoData else { return false }
        let downloadedData = videoData
        let downloadedDataLength = Int64(downloadedData.count)

        let requestRequestedOffset = dataRequest.requestedOffset
        let requestRequestedLength = Int64(dataRequest.requestedLength)
        let requestCurrentOffset = dataRequest.currentOffset

        if downloadedDataLength < requestCurrentOffset {
            return false
        }

        let downloadedUnreadDataLength = downloadedDataLength - requestCurrentOffset
        let requestUnreadDataLength = requestRequestedOffset + requestRequestedLength - requestCurrentOffset
        let respondDataLength = min(requestUnreadDataLength, downloadedUnreadDataLength)

        dataRequest.respond(with: downloadedData.subdata(in: Range(NSMakeRange(Int(requestCurrentOffset), Int(respondDataLength)))!))

        let requestEndOffset = requestRequestedOffset + requestRequestedLength

        return requestCurrentOffset >= requestEndOffset

    }
}

// MARK: - AVAssetResourceLoader Delegate
extension VideoPlayerView: AVAssetResourceLoaderDelegate {
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if task == nil, let url = originalURL {
            let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
            task = session?.dataTask(with: request)
            task?.resume()
        }
        self.loadingRequests.append(loadingRequest)
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        if let index = self.loadingRequests.firstIndex(of: loadingRequest) {
            self.loadingRequests.remove(at: index)
        }
    }
}

extension URL {
    /// Adds the scheme prefix to a copy of the receiver.
    func convertToRedirectURL(scheme: String) -> URL? {
        var components = URLComponents.init(url: self, resolvingAgainstBaseURL: false)
        let schemeCopy = components?.scheme ?? ""
        components?.scheme = schemeCopy + scheme
        return components?.url
    }
    
    /// Removes the scheme prefix from a copy of the receiver.
    func convertFromRedirectURL(prefix: String) -> URL? {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: false) else {return nil}
        guard let scheme = comps.scheme else {return nil}
        comps.scheme = scheme.replacingOccurrences(of: prefix, with: "")
        return comps.url
    }
}
