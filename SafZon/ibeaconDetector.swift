//
//  ibeaconDetector.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI
import Combine
import CoreLocation
import MapKit
import UserNotifications

class BeaconDetector: NSObject, CLLocationManagerDelegate, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var locationManager: CLLocationManager?
    var lastDistance = CLLocationAccuracy.nan
    var lastProximity = CLProximity.unknown
    var notificationShown = false
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
//        locationManager?.requestWhenInUseAuthorization()
        
        // Request "Always" authorization for location updates
                locationManager?.requestAlwaysAuthorization()
                
                // Set up location updates in the background
                locationManager?.allowsBackgroundLocationUpdates = true
                locationManager?.pausesLocationUpdatesAutomatically = false
                locationManager?.startMonitoringSignificantLocationChanges()
        
    }
    
    func sendNotification(withTitle title: String, andBody body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "beaconNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "B203A5EE-BF72-4B90-86FB-D5F23EEA6D44")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
            if let beacon = beacons.first {
                let distance = beacon.accuracy
                let proximity = beacon.proximity

                update(distance: distance, proximity: proximity)

                if beacon.proximity == .far ||
                   beacon.proximity == .immediate ||
                   beacon.proximity == .near {
                    if notificationShown == false {
                        sendNotification(withTitle: "Beacon Detected", andBody: "You are in immediate proximity to the beacon.")
                        notificationShown = true
                    }
                } else if beacon.proximity == .unknown {
                    notificationShown = false
                }
            } else {
                notificationShown = false
                update(distance: 0.0, proximity: .unknown)
            }
        }

    
    func update(distance: CLLocationAccuracy, proximity: CLProximity) {
        lastDistance = distance
        print(lastDistance)
        lastProximity = proximity
        self.objectWillChange.send()
    }
    
}

struct ibeaconDetector: View {
    
    @ObservedObject var detector = BeaconDetector()
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -6.302445, longitude: 106.6521382), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var distance: Double = 0.0
    
    var body: some View {
        GeometryReader{ reader in
            
        
        ZStack {
            
            if detector.lastProximity == .immediate {
                VStack{
                    Text("Right Here")
                        .font(Font.system(size: 72, design: .rounded))
//                        .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
//                        .background(Color.red)
                        .edgesIgnoringSafeArea(.all)
                    Text("\(detector.lastDistance, specifier: "%.2f")")
//                        .font(Font.system(size: 72, design: .rounded))
//                        .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
//                        .background(Color.red)
//                        .edgesIgnoringSafeArea(.all)
                }
                .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                .background(Color.red)
            } else if detector.lastProximity == .near {
                VStack {
                    Text("NEAR")
                        .font(Font.system(size: 72, design: .rounded))
                        
                    .edgesIgnoringSafeArea(.all)
                    Text("\(detector.lastDistance, specifier: "%.2f")")
                }
                .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                .background(Color.orange)
               
            } else if detector.lastProximity == .far {
                VStack {
                    Text("FAR")
                        .font(Font.system(size: 72, design: .rounded))
                    .edgesIgnoringSafeArea(.all)
                    Text("\(detector.lastDistance, specifier: "%.2f")")
                }
                .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                .background(Color.blue)
                
            } else {
                Text("UNKNOWN")
                
                    .font(Font.system(size: 72, design: .rounded))
                    .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                    .background(Color.gray)
                    .edgesIgnoringSafeArea(.all)
//                Text("\(detector.lastDistance, specifier: ".2")")
                //                .opacity(0.6)
            }
            Map(coordinateRegion: $region, showsUserLocation: true)
                .onAppear {
                    if let userLocation = locationManager.userLocation {
                        region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                    }
                }
                .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
//                .ignoresSafeArea()
                .opacity(0.5)
        }
        .onAppear {
            detector.startScanning()
        }
        }
        
    }
}

struct ibeaconDetector_Previews: PreviewProvider {
    static var previews: some View {
        ibeaconDetector()
    }
}
