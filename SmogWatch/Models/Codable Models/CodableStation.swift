//
//  CodableStation.swift
//  SmogWatch
//
//  Created by Filip Szukala on 21/10/2018.
//  Copyright © 2018 Filip Szukala. All rights reserved.
//

import Foundation

struct CodableStation: Decodable {
    let id: Int?
    let stationName: String?
    let gegrLat: String?
    let gegrLon: String?
    let city: CodableCity?
    let addressStreet: String?
}
