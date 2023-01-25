//
//  ViewController.swift
//  Weather Forecast
//
//  Created by Thanh Hai NGUYEN on 28/09/2021.
//
// MARK: - Improvement: when scroll down, city name is shown on navigation bar

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, LocationViewControllerDelegate {
    
    //outlets
    @IBOutlet var locationSharing: UIButton!{
        didSet{
            locationSharing.layer.cornerRadius = 25.0
            locationSharing.addTarget(self, action: #selector(userPressedLocationButton), for: .touchUpInside)
        }
    }
    @IBOutlet var chooseBG: UIButton!
    @IBOutlet var background: UIImageView!
    @IBOutlet var ImageView: UIImageView!
    @IBOutlet var time: UILabel?
    @IBOutlet var feels_like: UILabel!
    @IBOutlet var situation: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var temperature: UILabel!
    @IBOutlet weak var table: UITableView!{
        didSet {
            table.delegate = self
            table.dataSource = self
        }
    }
    @IBOutlet weak var table1: UITableView!{
        didSet{
            table1.delegate = self
            table1.dataSource = self
        }
    }
    var alertController: UIAlertController?
    var picker = UIImagePickerController()
    var labelForCurrent = ["11","8.45","95","18","1"]
    var daysForecast = [Daily]()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        picker.delegate = self
        getUserLocation()
        timeManager()
    }
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mySegue" {
            let vc = segue.destination as? LocationViewController
            vc?.delegate = self
        }
    }
    
    func myTextFieldDidWork(controller: LocationViewController, lat: Double, lon: Double) {
        Location.sharedInstance.longitude = lon
        Location.sharedInstance.latitude = lat
        self.daysForecast.removeAll()
        getWeather(Location.sharedInstance.latitude, lon: Location.sharedInstance.longitude)
        getLocationName(Location.sharedInstance.latitude, lon: Location.sharedInstance.longitude)
        controller.navigationController?.popViewController(animated: true)
        locationManager.stopUpdatingLocation()
    }
    // MARK: - Time
    func timeManager() {
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateStyle = .medium
        utcDateFormatter.timeStyle = .short
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let date = Date()
            self.time?.text = utcDateFormatter.string(from: date)
        }
    }
    // MARK: - Location
    func getUserLocation(){
        locationManager.delegate = self
        locationManager.distanceFilter = 100.0;
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            Location.sharedInstance.latitude = location.coordinate.latitude
            Location.sharedInstance.longitude = location.coordinate.longitude
            self.daysForecast.removeAll()
            getWeather(Location.sharedInstance.latitude, lon: Location.sharedInstance.longitude)
            getLocationName(Location.sharedInstance.latitude, lon: Location.sharedInstance.longitude)
        }
    }
    
    @objc func userPressedLocationButton(sender: Any){
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - API, JSON, HTTPS
    func getLocationName(_ lat: Double, lon: Double){
        var endpointLocationName = Endpoint()
        endpointLocationName.path = "/data/2.5/weather"
        endpointLocationName.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: "4858a234b2f80452c562d5ff6787aea6"),
            URLQueryItem(name: "units", value: "metric")
        ]
        request(endpointLocationName, type: name.self) { result in
            switch result {
            case .failure(let error):
                print(error.rawValue)
                
            case .success(let data):
                DispatchQueue.main.sync {  //try sync too
                    self.locationName.text = data.name
                }
            }
        }
    }
    
    func getWeather (_ lat: Double, lon: Double) {
        var endpointOneCall = Endpoint()
        endpointOneCall.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: "4858a234b2f80452c562d5ff6787aea6"),
            URLQueryItem(name: "exclude", value: "minutely,alerts,hourly"),
            URLQueryItem(name: "units", value: "metric"),
            
        ]
        request(endpointOneCall, type: OneCall.self) { result in
            switch result {
            case .failure(let error):
                print(error.rawValue)
                
            case .success(let oneCall):
                DispatchQueue.main.async {
                    self.temperature.text = String(format: "%.0f", round(oneCall.current.temp))+"°"
                    self.feels_like.text = "Feels like " + String(format: "%.0f", round(oneCall.current.feels_like))+"°"
                    self.situation.text = oneCall.current.weather[0].main
                    self.ImageView.image = UIImage(named: self.situation.text!) ?? UIImage(named: "else.png")
                    let days = oneCall.daily
                    for day in days {
                        self.daysForecast.append(day)
                    }
                    self.table.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        if tableView == self.table {
            count = daysForecast.count
        }
        
        if tableView == self.table1 {
            count =  labelForCurrent.count
        }
        
        return count!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.table {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyForecastTableViewCell", for: indexPath) as! DailyForecastTableViewCell
            cell.configure(with: daysForecast[indexPath.row])
          //  print("\(#function) --- section = \(indexPath.section), row = \(indexPath.row)")
            return cell
        }
        if tableView == self.table1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
            cell.configure(with: labelForCurrent[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: - Background Changes
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.background.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func chooseBG (sender: Any){
        print("Touch up inside")
        alertController = UIAlertController(title: "Change background image", message: "Choose image source: ", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            print("Camera")
            self.openCamera()
             
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            print("Photo Library")
            self.openPhotoLibrary()
        }
        alertController?.addAction(cameraAction)
        alertController?.addAction(photoLibraryAction)
        self.present(alertController!, animated: true) {
            print("alert")
        }
    }
    
    func openCamera(){
        guard (UIImagePickerController.isSourceTypeAvailable(.camera)) else {
            return
        }
        picker.allowsEditing = true
        picker.sourceType = .camera
        self.present(picker, animated: true) {
            print("Camera selected")
        }
    }
    
    func openPhotoLibrary(){
        guard (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) else {
            return
        }
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true) {
            print("photo selected")
        }
    }
}


