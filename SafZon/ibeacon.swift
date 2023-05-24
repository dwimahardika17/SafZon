//
//  ibeacon.swift
//  SafZon
//
//  Created by I MADE DWI MAHARDIKA on 24/05/23.
//

import Foundation
import CoreLocation
import CoreBluetooth


class BeaconDelegate: NSObject, CBPeripheralManagerDelegate, ObservableObject {
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

        func initLocalBeacon() {
            if localBeacon != nil {
                stopLocalBeacon()
            }

            let localBeaconUUID = "B203A5EE-BF72-4B90-86FB-D5F23EEA6D44"
            let localBeaconMajor: CLBeaconMajorValue = 123
            let localBeaconMinor: CLBeaconMinorValue = 456

            let uuid = UUID(uuidString: localBeaconUUID)!
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Your private identifer here")

            beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: false, CBPeripheralManagerOptionRestoreIdentifierKey: "your-unique-identifier"])

            print(localBeaconUUID)
            print(localBeaconMajor)
            print(localBeaconMinor)
        }

        func stopLocalBeacon() {
            peripheralManager.stopAdvertising()
            peripheralManager = nil
            beaconPeripheralData = nil
            localBeacon = nil
        }

        func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
            if peripheral.state == .poweredOn {
                peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
            } else if peripheral.state == .poweredOff {
                peripheralManager.stopAdvertising()
            }
        }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed to start advertising: \(error.localizedDescription)")
        } else {
            print("Advertising started")
        }
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
           // Handle the restoration of peripheral manager state
           // You may need to restore any necessary data or state here
       }
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Save any relevant data or state
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Restore any saved data or state
//    }
}
