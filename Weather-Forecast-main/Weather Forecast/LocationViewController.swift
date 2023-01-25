//
//  LocationViewController.swift
//  Weather Forecast
//
//  Created by Thanh Hai NGUYEN on 08/10/2021.
//

import UIKit

protocol LocationViewControllerDelegate{
    func myTextFieldDidWork(controller:LocationViewController,lat:Double, lon: Double)
}

class LocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var indicator: UILabel!
    @IBOutlet weak var inputField:UITextField!
    
    var delegate: LocationViewControllerDelegate? = nil
    var latitude: Double = 0.0
    var longitude = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.text = "Enter a location name."
        // Do any additional setup after loading the view.
        inputField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputField.resignFirstResponder()
        if let text = inputField.text, !text.isEmpty, delegate != nil {
            getCoordinates(text)
        }
        return true
    }
    
    
    func getCoordinates(_ text: String){
        var endpointLocation = Endpoint()
        endpointLocation.path = "/geo/1.0/direct"
        endpointLocation.queryItems.append(URLQueryItem(name: "q", value: text))
        endpointLocation.queryItems.append(URLQueryItem(name: "limit", value: "1"))
        request(endpointLocation, type: [Coordinates].self) { result in
            switch result {
            case .failure(let error):
                print(error.rawValue)
                
            case .success(let data):
                DispatchQueue.main.sync {
                    if data.isEmpty{
                        self.indicator.text = "No result."
                    }
                    for coordinate in data {
                        self.latitude = coordinate.lat
                        self.longitude = coordinate.lon
                        self.delegate?.myTextFieldDidWork(controller: self, lat: self.latitude, lon:self.longitude)
                    }
                }
            }
        }
    }

    deinit {
        print("Location VC is deinitialised")
    }
}


