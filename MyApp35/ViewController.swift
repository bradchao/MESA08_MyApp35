//
//  ViewController.swift
//  MyApp35
//
//  Created by user22 on 2017/10/6.
//  Copyright © 2017年 Brad Big Company. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    var mgr:CBCentralManager? = nil
    var connectPeripheral:CBPeripheral? = nil
    var chars:[String:CBCharacteristic] = [:]
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Scan ALL
        mgr?.scanForPeripherals(withServices: nil, options: nil)
        // Scan到之後, 觸發 didDiscover method
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == nil{
            print("n/a")
        }else{
            print("\(peripheral.name!)")
            
            if peripheral.name == "歡迎使用" {
                connectPeripheral = peripheral
                getData(peripheral)
            }
        }
    }
    

    private func getData(_ peripheral: CBPeripheral){
        mgr?.stopScan()
        peripheral.delegate = self
        print("getData()")
        // 我要連線
        
        mgr?.connect(connectPeripheral!, options: nil)
        
    }
    
    // 找出 設備上的 service
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 此處連接成功
        print("Connect Success")
        connectPeripheral!.discoverServices(nil)
    }
    
    // 找到特定的 service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("error = \(error)")
        }
        for service in connectPeripheral!.services! {
            print("service: \(service.uuid.uuidString)")
            // 掃到 Service, 繼續往下找 Characteristics
            connectPeripheral?.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 找到特定的功能
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for char in service.characteristics! {
            print("char: \(char.uuid.uuidString)")
            
            chars[char.uuid.uuidString] = char
            
            // 設定該功能為Notify
            connectPeripheral?.setNotifyValue(true, for: char)

        }
        
    }

    // 訂閱資料
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("OK")
        if characteristic.uuid.uuidString == "2A19" {
            var n:UInt8 = 0
            let data = characteristic.value as! NSData
            data.getBytes(&n, length: MemoryLayout<UInt8>.size)
            n = n.bigEndian
            print("value = \(n)")
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue = DispatchQueue.global()
        mgr = CBCentralManager(delegate: self, queue: queue)
        
    }

}

