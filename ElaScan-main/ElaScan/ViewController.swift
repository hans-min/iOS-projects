//
//  ViewController.swift
//  ElaScan
//
//  Created by Thanh Hai NGUYEN on 23/11/2021.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController, UITabBarControllerDelegate {
    private var centralManager: CBCentralManager!
    @IBOutlet var table: UITableView?{
        didSet {
            table?.delegate = self
            table?.dataSource = self
        }
    }
    var peripherals: [String:CBPeripheral] = [:]
    var connectedPeripheral: CBPeripheral? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }

    deinit{
        print("VC deinit")
    }
}

extension ViewController:CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("startScanning")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("stopScanning")
            centralManager.stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name else { return }
        if name.hasPrefix("P BUZZ") {
            peripherals[name] = peripheral
            table?.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(String(describing: peripheral.name))")
        centralManager.stopScan()
        peripheral.discoverServices(nil)
        tabBarController?.selectedIndex = 1
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.connectedPeripheral {
            print("Disconnected")
        }
        connectedPeripheral = nil
        tabBarController?.selectedIndex = 0
        peripherals.removeAll()
        table?.reloadData()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Fail to connect")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let index = peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)
        config.text = peripherals[index].key
        cell.contentConfiguration = config
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = peripherals.index(peripherals.startIndex, offsetBy: indexPath.row)
        connectedPeripheral = peripherals[index].value
        let cvc = tabBarController?.viewControllers?[1] as! ConnectedViewController
        centralManager.connect(connectedPeripheral!, options: nil)
        connectedPeripheral?.delegate = cvc
    }
}

