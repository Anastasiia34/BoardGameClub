//
//  NonClusteringMKMarkerAnnotationView.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 25.11.2021.
//

import MapKit
import UIKit

class NonClusteringMKMarkerAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            displayPriority = MKFeatureDisplayPriority.required
        }
    }

}
