//
//  LocationManager.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI
import CoreLocation
import MapKit
import Firebase
import CoreData
import UserNotifications

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
//    private let locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion()
    private var firestore: Firestore!
    private var timer: Timer?
//    private var context: NSManagedObjectContext
    private var coreDataManager: CoreDataManager
    @Published var annotations = [MKPointAnnotation]()

    override init() {
        coreDataManager = CoreDataManager.shared
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        firestore = Firestore.firestore()
        
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
//            self?.saveUserLocation()
            self?.retrieveGeofenceData()
            self?.fetchData()
        }
    }
    
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        
        if let userLocation = locations.last {
            region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            if region is CLCircularRegion {
                print("Entered geofence: \(region.identifier)")
//                showNotification(title: "Geofence Alert", body: "You are inside the geofence.")
                // Perform actions when entering a geofence
                sendNotification(withTitle: "geofence", andBody: "123")
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            if region is CLCircularRegion {
                print("Exited geofence: \(region.identifier)")
//                showNotification(title: "Geofence Alert", body: "You have exited the geofence.")
                // Perform actions when exiting a geofence
                sendNotification(withTitle: "out", andBody: "321")
            }
    }
    
    func sendNotification(withTitle title: String, andBody body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "geofence", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func startGeofencing() {
        if let userLocation = locationManager.location {
            let geofenceRegion = CLCircularRegion(center: userLocation.coordinate, radius: 50, identifier: "Geofence")
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = true
            locationManager.startMonitoring(for: geofenceRegion)
            
            // Save geofence data to Firebase Firestore
            let userId = Auth.auth().currentUser?.uid// Get the user's ID from the user session
            let geofenceData: [String: Any] = [
                "userId": userId,
                "latitude": userLocation.coordinate.latitude,
                "longitude": userLocation.coordinate.longitude,
                "radius": 50
            ]
            print(userLocation.coordinate.latitude)
            print(userLocation.coordinate.longitude)
            firestore.collection("geofences").addDocument(data: geofenceData) { error in
                if let error = error {
                    print("Error saving geofence data: \(error)")
                } else {
                    print("Geofence data saved successfully")
                }
            }
        }
    }
    
    func retrieveGeofenceData() {
        firestore.collection("geofences").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error retrieving geofence data: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for document in snapshot.documents {
                let data = document.data()
                
                // Extract relevant data from the Firestore document
                guard let userId = data["userId"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let radius = data["radius"] as? Double else {
                    continue
                }
                
                // Check if an existing object with the same userId already exists in Core Data
                let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
                
                do {
                    let existingGeofences = try coreDataManager.context.fetch(fetchRequest)
                    
                    if let existingGeofence = existingGeofences.first {
                        // Update the existing object instead of creating a new one
                        existingGeofence.latitude = latitude
                        existingGeofence.longitude = longitude
                        existingGeofence.radius = radius
                    } else {
                        // Create a new Core Data object
                        let newGeofence = Entity(context: coreDataManager.context)
                        newGeofence.userId = userId
                        newGeofence.latitude = latitude
                        newGeofence.longitude = longitude
                        newGeofence.radius = radius
                    }
                    
                    // Save the Core Data context
                    try coreDataManager.context.save()
                    print("Geofence data saved successfully")
                } catch {
                    print("Error saving Core Data context: \(error)")
                }
            }
        }
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        var userGeofences = [Entity]()

        do {
            let geofences = try coreDataManager.context.fetch(fetchRequest)
            userGeofences = geofences

            var fetchedAnnotations = [MKPointAnnotation]() // Temporary array to store fetched annotations

            for geofence in userGeofences {
                let lat: CLLocationDegrees = geofence.latitude
                let long: CLLocationDegrees = geofence.longitude
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = geofence.userId

                fetchedAnnotations.append(annotation)

                let region = CLCircularRegion(center: coordinate, radius: geofence.radius, identifier: geofence.userId!)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                locationManager.startMonitoring(for: region)
                print(geofence.latitude)
                print(geofence.longitude)
            }

            annotations = fetchedAnnotations // Update the published property

            print("Successfully fetched geofences")
        } catch {
            print("Failed to fetch geofences: \(error)")
        }
    }
    
    func deleteData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let query = firestore.collection("geofences").whereField("userId", isEqualTo: userId)
        
        query.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error deleting geofences: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            for document in snapshot.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting geofence document: \(error)")
                    } else {
                        print("Geofence document deleted successfully")
                    }
                }
            }
            
            // Delete the corresponding Core Data objects
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
            
            do {
                let geofences = try self.coreDataManager.context.fetch(fetchRequest)
                
                for geofence in geofences {
                    self.coreDataManager.context.delete(geofence)
                }
                
                try self.coreDataManager.context.save()
                print("Geofences deleted successfully")
            } catch {
                print("Failed to delete geofences from Core Data: \(error)")
            }
        }
    }
    func deleteDataFromCoreData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let geofences = try coreDataManager.context.fetch(fetchRequest)
            
            for geofence in geofences {
                coreDataManager.context.delete(geofence)
            }
            
            try coreDataManager.context.save()
            print("Geofences deleted successfully")
        } catch {
            print("Failed to delete geofences from Core Data: \(error)")
        }
    }


}
