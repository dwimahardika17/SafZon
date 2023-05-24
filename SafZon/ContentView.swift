//
//  ContentView.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI
import MapKit
import UIKit

struct ContentView: View {
    
    @ObservedObject private var ibeaconClass = BeaconDelegate()
    @State private var isOn = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        GeometryReader{ reader in
            VStack {
                if isOn == false {
                    VStack {
                        Button{
                            ibeaconClass.initLocalBeacon()
                            locationManager.startGeofencing()
                            isOn.toggle()
                        } label: {
                            Image("Panic")
                                .resizable()
                                .frame(width: 300, height: 300)
                                
                        }
                        .position(x:reader.frame(in: .global).maxX*0.5, y: reader.frame(in: .global).maxY*0.5)
                    }
                    .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                } else {
                    VStack {
                        Button{
                            ibeaconClass.stopLocalBeacon()
                            locationManager.deleteData()
                            locationManager.deleteDataFromCoreData()
                            isOn.toggle()
                        } label: {
                            Image("Off")
                        }
                        .position(x:reader.frame(in: .global).maxX*0.5, y: reader.frame(in: .global).maxY*0.5)
                        Text("Your Location is Broadcasted")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .position(x:reader.frame(in: .global).maxX*0.5, y: reader.frame(in: .global).maxY*0.3)
                            .foregroundColor(.white)
                        
                        
                    }
                    .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                    .background(Color(hex: 0xCD2118))
                    
                    
                }
                
                
            }
            
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
