//
//  APIManager.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class APIManager: NSObject {
    
    enum DataManagerError: Error {
        case Unknown
        case FailedRequest
        case InvalidResponse
        
    }
    typealias Completion = (AnyObject, DataManagerError?) -> ()
    static let shared = APIManager()

    private override init() { }
                
    func fetchAPIDetails(url : String, Stringmethod : String, params : Dictionary<String, AnyObject> , completion: @escaping Completion){
        let url = URL(string: url)
        print(url!)
        AF.request(self.setURLRequest(stringUrl: url!, Stringmethod: Stringmethod, params: params))
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let data = response.data {
                        let json = JSON(data)
                        print(json)
                        completion(data as AnyObject,nil)
                    }
                case .failure(let error):
                    print(error)
                    completion(Data() as AnyObject, nil)
                }
        }
    }

    // MARK: - API request object
    func setURLRequest(stringUrl : URL, Stringmethod : String, params : Dictionary<String, AnyObject>)-> URLRequest {
        // input parameters //
        let aDataParameter = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        // create API request object //
        var request = URLRequest(url: stringUrl)
        request.timeoutInterval = 120
        request.httpMethod = (Stringmethod == "GET") ? HTTPMethod.get.rawValue : (Stringmethod == "POST") ? HTTPMethod.post.rawValue :(Stringmethod == "PUT") ?  HTTPMethod.put.rawValue : HTTPMethod.delete.rawValue
//        request.setValue("form-data", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request = setCommonContenHeaders(urlRequest: request)
        // data convert to JSON format //
        let json = NSString(data: aDataParameter, encoding: String.Encoding.utf8.rawValue)
        if let json = json {
            print(json)
        }
        // http body //
        if ((request.httpMethod == "POST") || (request.httpMethod == "PUT") || (request.httpMethod == "DELETE")) {
            request.httpBody = json!.data(using: String.Encoding.utf8.rawValue)
        }
        return request
    }
    func setCommonContenHeaders(urlRequest: URLRequest) -> URLRequest  {
        var request = urlRequest
        request.setValue("iOS", forHTTPHeaderField: "platform")
        return request
    }

}
