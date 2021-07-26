//
//  ErrorHelpers.swift
//  AuxBox
//
//  Created by Ivan Teo on 24/5/21.
//

import Foundation

enum NetworkError: String, Error{
    case invalidAccount = "You're not logged into our server. Please contact us for help"
    case invalidResponse = "Invalid response from the server, please try again"
    case invalidData = "The data received from the server was invalid, please try again"
    case requestError = "There was an error with the request. Please try again."
    case decodingError = "There was an error decoding the data. Please try again."
}
