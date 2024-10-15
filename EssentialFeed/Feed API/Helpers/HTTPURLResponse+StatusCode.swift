//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import Foundation

extension HTTPURLResponse {
    public static var OK_200: Int { 200 }

    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
