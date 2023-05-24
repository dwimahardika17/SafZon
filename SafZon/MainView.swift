//
//  MainView.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        GeometryReader { reader in
            
        
            TabView {
                ContentView()
                    .tabItem {
                        Label("Button", systemImage: "button.programmable")
                    }
                
                    .background(Color.white)
                    .position(x: reader.frame(in: .global).maxX*0.5, y: reader.frame(in: .global).maxX*0.97)
                    .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
                    
                    
                ibeaconDetector()
                    .tabItem {
                        Label("Radar", systemImage: "map.circle.fill")
                    }
                    .background(Color.white)
                    .position(x: reader.frame(in: .global).maxX*0.5, y: reader.frame(in: .global).maxX*0.97)
                    .frame(width: reader.frame(in: .global).maxX, height: reader.frame(in: .global).maxY)
            }
//            .frame(height: 100)
//            .opacity(0)
//            .background(Color.green)
            .accentColor(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0))
            
            
        }
            
 
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
