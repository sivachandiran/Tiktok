//
//  HTTPError.swift
//  TikTak
//
//  Created by SIVA on 03/03/21.
//

import Foundation

enum HTTPError: Error {
    case failureParsingHTTPResponse
}

extension HTTPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failureParsingHTTPResponse:
            return "Error parsing HTTPResponse."
        }
    }
}
