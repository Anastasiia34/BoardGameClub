//
//  ViewController.swift
//  BoardGameClub
//
//  Created by Анастасия Стрекалова on 23.11.2021.
//

import CloudKit
import MapKit
import UIKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private var clubs: [Club] = []
    private var userCoordinate: CLLocationCoordinate2D?
    private var userURL: URL?
    private let geocoder = CLGeocoder()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        loadClubs()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: { [weak self] placemarks, error  in
            if (placemarks?.first?.ocean) == nil {
                self?.userCoordinate = coordinate
                self?.presentClubCreatioinViewController()
            } else {
                self?.showAlert(title: "You can't place a pin in the ocean", message: "Please choose another location")
            }
        })
    }
    
    private func presentClubCreatioinViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ClubCreationViewController") as! ClubCreationViewController
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func presentClubJoiningViewController(club: Club) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ClubJoiningViewController") as! ClubJoiningViewController
        vc.club = club
        present(vc, animated: true)
    }
    
    private func showAlert(title: String, message: String?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(ac, animated: true)
    }
}

// MARK: GameViewControllerDelegate
extension MapViewController: ClubCreationViewControllerDelegate {
    func clubCreated(url: URL, clubName: String, creatorName: String) {
        guard let coordinate = userCoordinate else {
            return
        }
        let club = Club(coordinate: coordinate, url: url, clubName: clubName, creatorName: creatorName)
        clubs.append(club)
        saveClub(club)
        dismiss(animated: true)
    }
}

// MARK: Map Kit
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let selectedCoordinate = view.annotation?.coordinate
        if let club = clubs.filter({ $0.coordinate.latitude == selectedCoordinate?.latitude && $0.coordinate.longitude == selectedCoordinate?.longitude }).first {
            presentClubJoiningViewController(club: club)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker")
    }
}

// MARK: Cloud Kit
extension MapViewController {
    private func loadClubs() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "Location", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let self = self else {
                return
            }
            
            guard error == nil, let records = records else {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(title: "Could't load clubs", message: error?.localizedDescription ?? "")
                }
                return
            }
            
            for record in records {
                if
                    let location = record["coordinate"] as? CLLocation,
                    let urlString = record["url"] as? String,
                    let url = URL(string: urlString),
                    let clubName = record["clubName"] as? String,
                    let creatorName = record["creatorName"] as? String
                {
                    let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let club = Club(coordinate: coordinate, url: url, clubName: clubName, creatorName: creatorName)
                    self.clubs += [club]
                }
            }
            
            let annotations = self.clubs.map { location -> MKAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                return annotation
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.mapView.addAnnotations(annotations)
            }
        }
    }
    
    private func saveClub(_ club: Club) {
        let record = CKRecord(recordType: "Location")
        record["coordinate"] = CLLocation(latitude: club.coordinate.latitude, longitude: club.coordinate.longitude)
        record["url"] = club.url?.absoluteString ?? ""
        record["clubName"] = club.name
        record["creatorName"] = club.creatorName
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.save(record) { [weak self] record, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.showAlert(title: "Couldn't save your location", message: error.localizedDescription)
                }
                
                if record != nil {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = club.coordinate
                    self?.mapView.addAnnotation(annotation)
                }
            }
        }
    }
}
