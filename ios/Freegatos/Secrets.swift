//
//  Secrets.swift
//  freegato
//
//  Created by Chris Wong on 27/3/2026.
//

import Foundation

enum Secrets {
    static let catAPIKey = Bundle.main.infoDictionary!["API_URL"] as! String
}
