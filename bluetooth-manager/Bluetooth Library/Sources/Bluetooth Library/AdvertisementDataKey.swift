//
//  AdvertisementDataKey.swift
//  Squiddy
//

import CoreBluetooth

///https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/advertisement_data_retrieval_keys
struct AdvertisementDataKey {
    //Documented keys
    static let localName = CBAdvertisementDataLocalNameKey
    static let manufacturerData = CBAdvertisementDataManufacturerDataKey
    static let serviceData = CBAdvertisementDataServiceDataKey
    static let serviceUUIDs = CBAdvertisementDataServiceUUIDsKey
    static let overflowServiceUUIDs = CBAdvertisementDataOverflowServiceUUIDsKey
    static let txPowerLevel = CBAdvertisementDataTxPowerLevelKey
    static let isConnectable = CBAdvertisementDataIsConnectable
    static let solicitedServiceUUIDs = CBAdvertisementDataSolicitedServiceUUIDsKey
    
    //Undocumented keys - these keys are supported by Apple but are not documented any where
    static let timestamp = "kCBAdvDataTimestamp"
    static let rxPrimaryPHY = "kCBAdvDataRxPrimaryPHY"
    static let rxSecondaryPHY = "RxSecondaryPHY"
}

public class PeripheralWithData: NSObject {
    public var peripheral: CBPeripheral
    public var name: String
    public var rawData: [String:Any]

    public init(peripheral: CBPeripheral, name: String, rawData: [String : Any]) {
        self.peripheral = peripheral
        self.name = name
        self.rawData = rawData
    }
}
