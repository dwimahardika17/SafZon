//
//  GeofenceDetector.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI
import SwiftUI
import MapKit
import CoreLocation
import Firebase
import CoreData
import UserNotifications

//struct AnnotationItem: Identifiable {
//    let id = UUID()
//    let annotation: MKPointAnnotation
//}

struct GeofenceDetector: View {
    @StateObject private var locationManager = LocationManager()
    @State private var annotationItems = [AnnotationItem]()
    var body: some View {
        VStack {
          
            Map(coordinateRegion: $locationManager.region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: annotationItems) { item in
                    MapAnnotation(coordinate: item.annotation.coordinate) {
                        Image(systemName: "mappin")
                    }
                }
                .edgesIgnoringSafeArea(.all)
        }
//        .toolbar {
//            ToolbarItemGroup(placement: .navigationBarLeading) { Button(
//                action: { authModel.signOut()
//                }, label: {
//                    Text("Sign Out") .bold()
//                })
//            }
//        }
        .onAppear(perform: locationManager.retrieveGeofenceData)
        .onReceive(locationManager.objectWillChange, perform: { _ in
            // Update the annotationItems when the location manager's objectWillChange publisher emits a value
            annotationItems = locationManager.annotations.map { AnnotationItem(annotation: $0) }
        })
    }
    
}

struct GeofenceDetector_Previews: PreviewProvider {
    static var previews: some View {
        GeofenceDetector()
    }
}
