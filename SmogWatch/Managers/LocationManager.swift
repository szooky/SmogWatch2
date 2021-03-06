//
//  NearestStationManager.swift
//  SmogWatch
//
//  Created by Filip Szukala on 05/11/2018.
//  Copyright © 2018 Filip Szukala. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager {
    static var shared = LocationManager()
    private let locationManager = CLLocationManager()

    private func requestLocationAuthorization(on viewController: UIViewController) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            showLocationPreviouslyDeniedAlert(on: viewController)
        default:
            return
        }
    }

    func showLocationPreviouslyDeniedAlert(on viewController: UIViewController) {

        let alertController = UIAlertController (title: Texts.LocalizationDeniedAlert.title,
                                                 message: Texts.LocalizationDeniedAlert.message,
                                                 preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: Texts.LocalizationDeniedAlert.settingsAction, style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: Texts.General.cancel, style: .default) { _ in
        }
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }

    func getNearestStationIndex(withLocationAuthorizationRequestOnViewController viewController: UIViewController? = nil) -> Int? {
        locationManager.startUpdatingLocation()

        if let viewController = viewController {
            requestLocationAuthorization(on: viewController)
        }

        DataFlowManager.shared.fetchStations()
        guard let stations = Database.shared.getAllStations() else { return nil }
        guard let currentLocation = locationManager.location else { return nil }
        var minimumDistance = CLLocationDistanceMax
        var closestStation = stations.first

        for station in stations {
            if let stationLocation = station.coordinates {
                let distance = currentLocation.distance(from: stationLocation)
                if distance < minimumDistance {
                    closestStation = station
                    minimumDistance = distance
                }
            }
        }

        if let id = closestStation?.id {
            return Int(id)
        } else {
            return nil
        }
    }
}

