# iOS Bluetooth-manager
a lightweight bluetooth library that manages and minimize your workload on CoreBluetooh, so you can focus on the UI
<br>

## Import to your project
Version 1.0.0, iOS >= 15.0
<br>
Basically, adding a local Swift Package requires two steps:
1.  Download the Bluetooth Library folder
2.  Drag and drop the downloaded folder into your Xcode project or workspace.
3.  Add it to the `Frameworks, Libraries, and Embedded Content` section in app targets general pane.

##### or, you can go to the Sources folder and download all the .swift file and put them in your projects

 **Note**: Apple require permission to use bluetooth. Update `info.plist` by adding `Privacy - Bluetooth Peripheral Usage Description` and `Privacy - Bluetooth Always Usage Description`
 
 <img src="https://cdn-learn.adafruit.com/assets/assets/000/099/661/medium640/breakout_boards_Screen_Shot_2021-02-18_at_10.21.15_PM.png?1613704897">
 
 
 ## Usage

### Bluetooth Manager

 #### 1. Setup
 First of all, you need to import the Bluetooth_Library framework:
````swift
import Bluetooth_Library
````
Most of the work in the Bluetooth_Library framework will be done through delegate methods. The central manager is represented by `BluetoothManager` and its delegate is `BluetoothDelegate`.

Firstly, you can get instance of the Bluetooth Manager:
````swift
private var centralManager = BluetoothManager.getInstance()
````

Then, add the BluetoothDelegate extension to your class:
````swift
extension ViewController: BluetoothDelegate {

}
````
You also need to set the manager's delegate to your view controller:
````swift
override func viewDidLoad() {
	super.viewDidLoad()
	centralManager.delegate = self
}
````
#### 2. Scan devices
To start scanning, call `centralManager.startScan()`.<br>
To stop scannning, call `centralManager.stopScan()`.<br>
You can **only scan** when the `centralManager.state == .poweredOn`. You can get the BluetoothState from the delegate function `didUpdateState(_ state: BluetoothState)`. <br>
The scan result will be a array of `PeripheralWithData` containing the name, the `CBPeripheral` and the advertisement data.
You can then access the array by calling `centralManager.peripherals` (read-only). 

> You can remove all the elements in the `peripherals` array by calling `centralManager.removeAllPeripherals()` 

#### 3. Discover devices  
Upon the discovery of a peripheral, the `centralManager.peripherals` will be updated and the delegate function `didDiscoverPeripheral(_ peripheral: PeripheralWithData)` will be invoked. 
> You can update the UI from this function.

#### 4. Connect and disconnect from device**  
To connect to a peripheral, call the function `centralManager.connectPeripheral(_ peripheral: PeripheralWithData)`. If the manager successfully connect with the SquidHome, the delegate callback function `didConnectPeripheral(_ peripheral: PeripheralWithData)` will be invoked and the connected Squid will be saved to the variable `centralManager.connectedPeripheral`. The manager will then automatically discover all the services and the characteristics of the connected SquidHome. 
> If there is an error while discovering the device's characteristics, the callback function `didFailToDiscoverCharacteritics(_ error: Error)` will be invoked.
 
To disconnect from a peripherals, call the function `centralManager.disconnectPeripheral()`. The callback function `didDisconnectPeripheral(_ peripheral: SquiddInfo)` from the delegate will be invoked.

If the manager failed to connect to the peripheral, the function `failToConnectPeripheral(_ peripheral: SquiddInfo, error: Error?)` from the delegate will be invoked.

> **Note**: This SDK doesn't manage connection and disconnection with multiple devices. Remember to disconnect from the old device before connecting to a new device.

## Troubleshoot
