//
//  File.swift
//
//
//  Created by Thanh Hai NGUYEN on 30/09/2022.
//

import CoreBluetooth

public class BluetoothManager: NSObject {
    private static let sharedInstance = BluetoothManager()
    var centralManager: CBCentralManager?
    open weak var managerDelegate: BluetoothDelegate?
    var state: CBManagerState? {
        get {
            guard centralManager != nil else { return nil }
            return CBManagerState(rawValue: (centralManager?.state.rawValue)!)
        }
    }
    public private(set) var peripherals: [PeripheralWithData] = []
    public private(set) var connectedPeripheral: PeripheralWithData?
    private var characteristic: CBCharacteristic?
//    private weak var timeoutimer: Timer? {
//        didSet {
//            print("\(String(describing: timeoutimer)) changed.")
//            //NotificationCenter.default.post(name: .timerSet, object: nil)
//        }
//    }

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public static func getInstance() -> BluetoothManager {
        return sharedInstance
    }
}

//MARK: - update state
extension BluetoothManager: CBCentralManagerDelegate {
    /// Invoked whenever the central manager's state has been updated.
    /// - Parameter central: The central manager providing this update.
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is on.")
        case .poweredOff:
            print("Please turn on Bluetooth.")
        case .unsupported:
            print("Bluetooth ins't support on this device.")
        case .resetting:
            print("Connection is resetting. Updating state.")
        case .unauthorized:
            print("Bluetooth is not authorized. Please change in phone settings.")
        case .unknown:
            print("Bluetooth status can't be determined. Updating state.")
        @unknown default:
            print("Bluetooth status can't be determined. Updating state.")
        }
        if let state = self.state {
            managerDelegate?.didUpdateState(state)
        }
    }

    //MARK: - discover peripherals
    /**
     This method is invoked while scanning, upon the discovery of peripheral by central

     - parameter central:           The central manager providing this update.
     - parameter peripheral:        The discovered peripheral.
     - parameter advertisementData: A dictionary containing any advertisement and scan response data.
     - parameter RSSI:              The current RSSI of peripheral, in dBm. A value of 127 is reserved and indicates the RSSI
     *                                was not available.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var name = ""
        if let advName = advertisementData[AdvertisementDataKey.localName] as? String {
            name = advName
        } else {
            name = "N/A"
        }
        let info = PeripheralWithData(peripheral: peripheral, name: name, rawData: advertisementData)
        if let i = peripherals.firstIndex(where: { $0.name == info.name}) {
            peripherals[i] = info
        } else {
            peripherals.append(info)
        }
        managerDelegate?.didDiscoverPeripheral(info)
    }
}

//MARK: - didConnect
extension BluetoothManager {
    /**
     This method is invoked when a connection succeeded

     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that has connected.
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth Manager --> didConnectPeripheral")
        guard let peripheralWithData = peripherals.first(where: {$0.peripheral == peripheral}) else {
            print("\(peripheral) isn't found in the list")
            return
        }
        self.connectedPeripheral = peripheralWithData
        stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        managerDelegate?.didConnectPeripheral?(peripheral)
    }

    /**
     This method is invoked when the peripheral has been disconnected.

     - parameter central:    The central manager providing this information
     - parameter peripheral: The disconnected peripheral
     - parameter error:      The error message
     */
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didDisconnectPeripheral")
        self.managerDelegate?.didDisconnectPeripheral?(peripheral)
        connectedPeripheral = nil
        characteristic = nil

    }

    /**
     This method is invoked where a connection failed.

     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that you tried to connect.
     - parameter error:      The error infomation about connecting failed.
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didFailToConnectPeripheral")
        if connectedPeripheral?.peripheral == peripheral { connectedPeripheral = nil }
        managerDelegate?.failToConnectPeripheral?(peripheral, error: error!)
    }


    //MARK: - Scanning function
    /**
     The method provides for starting scan near by peripheral
     */
    public func startScan() {
        guard state == .poweredOn else {
            print("Bluetooth isn't power on")
            return
        }
        centralManager?.scanForPeripherals(withServices: nil)
    }

    /**
     The method provides for stopping scan near by peripheral
     */
    public func stopScan() {
        centralManager?.stopScan()
    }

    public func removeAllPeripherals() {
        peripherals.removeAll()
    }
    //MARK: - Connect peripheral
    /**
     The method provides for connecting the special peripheral

     - parameter peripheral: The peripheral you want to connect
     */
    public func connectPeripheral(_ peripheral: PeripheralWithData) {
        centralManager?.connect(peripheral.peripheral)
    }

    /**
     The method provides for disconnecting with the peripheral which has connected
     */
    public func disconnectPeripheral() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(connectedPeripheral.peripheral)
            print("Bluetooth Manager --> Disconnecting peripheral")
        }
    }
}
//MARK: - Peripheral Delegates
extension BluetoothManager: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        if let error = error {
            print("Bluetooth Manager --> Fail to discover services! Error: \(error.localizedDescription)")
        }
        print("Bluetooth Manager --> Discover services: \(services.count)")
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Bluetooth Manager --> Fail to discover characteristics! Error: \(error.localizedDescription)")
            managerDelegate?.didFailToDiscoverCharacteritics?(error)
            return
        }
        guard let characteristics = service.characteristics else {
            print("Characteristic not found")
            return
        }
        print("Bluetooth Manager --> Discovered Characteristics: \(characteristics.count)")
        for characteristic in characteristics {
            if characteristic.properties.contains(.read){
                peripheral.readValue(for: characteristic)
                print(".read")
            }
            peripheral.setNotifyValue(true, for: characteristic)
            self.characteristic = characteristic
            print("Bluetooth Manager --> discover characteristics: \(String(describing: self.characteristic))")
        }
    }

    /**
     Thie method is invoked when the user call the peripheral.readValueForCharacteristic

     - parameter peripheral:     The periphreal which call the method
     - parameter characteristic: The characteristic with the new value
     - parameter error:          The error message
     */
//    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("Bluetooth Manager --> didUpdateValueForCharacteristic")
//        if let error = error {
//            print("Bluetooth Manager --> Failed to read value for the characteristic. Error:\(error.localizedDescription)")
//            delegate?.didFailToReadValueForCharacteristic?(error)
//            return
//        }
//        guard let result = characteristic.value else {
//            print("Bluetooth Manager --> Failed to decode value for the characteristic: \(String(describing: characteristic.value))")
//            return
//        }
//        timeoutimer?.invalidate()
//        timeoutimer = nil
//        delegate?.didReadValueForCharacteristic?(characteristic: result)
//    }
}

extension BluetoothManager {
    /**
     Write value to the peripheral which is connected

     - parameter data:           The data which will be written to peripheral
     - parameter type:           The write of the operation
     */
//    public func writeValue(_ value: String, type: CBCharacteristicWriteType = .withoutResponse) -> Bool {
//        if characteristic == nil {
//            print("No characteristic")
//            return false
//        }
//        guard let data = value.dataFromHex() else {
//            print("can't encode message")
//            return false
//        }
//    }

//    @objc private func connectionTimeout() {
//        if receivingResponse {
//            receivingResponse = false
//            timeoutimer = nil
//        }
//    }
//
//    public func observeTimer(completion: @escaping (Bool) -> Void) {
//        NotificationCenter.default.addObserver(forName: .timerSet, object: nil, queue: nil) { [weak self] _ in
//            guard let self = self else { return }
//            if self.timeoutimer?.isValid == true {
//                completion(true)
//                print("Timer start")
//            } else {
//                completion(false)
//                print("Timer end")
//            }
//        }
//    }
}
//
//extension Notification.Name {
//    static let timerSet = Notification.Name("timerSet")
//}
