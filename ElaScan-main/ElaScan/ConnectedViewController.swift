//
//  ConnectedViewController.swift
//  ElaScan
//
//  Created by Thanh Hai NGUYEN on 24/11/2021.
//

import UIKit
import CoreBluetooth

class ConnectedViewController: UIViewController {
    
    @IBOutlet var notYet: UIImageView!
    @IBOutlet var buzzer: UISwitch!
    @IBOutlet var led: UISwitch!
    @IBOutlet var connectTo: UILabel!
    var peripheral: CBPeripheral? = nil
    var writeCharacteristic: CBCharacteristic?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cvc = tabBarController?.viewControllers?[0] as! ViewController
        self.peripheral = cvc.connectedPeripheral
        checkPeripheral()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        led.isOn = false
        buzzer.isOn = false
    }
    
    
    func checkPeripheral(){
        if peripheral != nil {
            connectTo.text = "Connected to: \(peripheral!.name ?? "NONE")"
            notYet.isHidden = true
        }
        else {
            notYet.isHidden = false
        }
    }
    @IBAction func ledOnOff(_ sender: UISwitch) {
        guard peripheral != nil else {return}
        if sender.isOn {
            let data = "LED_ON".data(using: String.Encoding.utf8)!
            writeValueToChar(withCharacteristic: writeCharacteristic!, withValue: data)
        } else {
            let data = "LED_OFF".data(using: String.Encoding.utf8)!
            writeValueToChar(withCharacteristic: writeCharacteristic!, withValue: data)
        }
    }
    
    @IBAction func buzzerOnOff(_ sender: UISwitch) {
        guard peripheral != nil else {return}
        if sender.isOn {
            let data = "BUZZ_ON".data(using: String.Encoding.utf8)!
            writeValueToChar(withCharacteristic: writeCharacteristic!, withValue: data)
        } else {
            let data = "BUZZ_OFF".data(using: String.Encoding.utf8)!
            writeValueToChar(withCharacteristic: writeCharacteristic!, withValue: data)
        }
    }
    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        if characteristic.properties.contains(.write){
            peripheral!.writeValue(value, for: characteristic, type: .withResponse)
        }
    }
}

extension ConnectedViewController: CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                writeCharacteristic = characteristic
            }
            if characteristic.properties.contains(.notify){
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
