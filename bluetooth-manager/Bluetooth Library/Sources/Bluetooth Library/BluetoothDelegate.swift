//
//  File.swift
//  
//
//  Created by Thanh Hai NGUYEN on 30/09/2022.
//

import CoreBluetooth

/**
 *  Bluetooth Model Delegate containing callback functions
 */
@objc public protocol BluetoothDelegate: NSObjectProtocol {

    /**
     The callback function when the bluetooth has updated.
     - parameter state: The newest state
     */
    @objc func didUpdateState(_ state: CBManagerState)

    /**
     The callback function when peripheral has been found.
     - parameter peripheral: The Squidd peripheral that has been found.
     */
    @objc func didDiscoverPeripheral(_ peripheral: PeripheralWithData)


    //MARK: - Connection with peripherals
    /**
     The callback function when central manager connected the peripheral successfully.
     - parameter connectedPeripheral: The Squidd peripheral which connected successfully.
     */
    @objc optional func didConnectPeripheral(_ peripheral: CBPeripheral)

    /**
    The callback function when the peripheral disconnected.
    - parameter peripheral: The Squidd peripheral which provide this action
    */
    @objc optional func didDisconnectPeripheral(_ peripheral: CBPeripheral)

    /**
     The callback function when central manager failed to connect the peripheral.
     - parameter connectedPeripheral: The Squidd peripheral which we failed to connect with.
     - parameter error:               The connected failed error message.
     */
    @objc optional func failToConnectPeripheral(_ peripheral: CBPeripheral, error: Error)


    //MARK: - Peripheral Services and Characteristics
    /**
     The callback function when peripheral failed to discover characteristics.
     - parameter error: The error information.
     */
    @objc optional func didFailToDiscoverCharacteritics(_ error: Error)

    /**
     The callback function invoked when peripheral read value from the characteristic successfully
     - parameter result: The response from the characteristics
     */
    @objc optional func didReadValueForCharacteristic(characteristic: CBCharacteristic)

    /**
     The callback function invoked when failed to read value for the characteristic
     - parameter error: The error message
     */
    @objc optional func didFailToReadValueForCharacteristic(_ error: Error)
}
