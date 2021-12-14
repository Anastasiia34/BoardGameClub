//
//  Location.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 23.11.2021.
//

import Foundation
import MapKit

class Club: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let url: URL?
    let name: String
    let creatorName: String

    init(
        coordinate: CLLocationCoordinate2D,
        url: URL?,
        clubName: String,
        creatorName: String
    ) {
        self.coordinate = coordinate
        self.url = url
        self.name = clubName
        self.creatorName = creatorName
        super.init()
    }
}
