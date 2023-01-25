//
//  Extension.swift
//  Weather Forecast
//
//  Created by Thanh Hai NGUYEN on 04/10/2021.
//

import Foundation

// MARK: - Date Extension to covert date to a day in String type.

extension Date {
    func dayOfTheWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}

//MARK: - Network Request function

func request<T:Decodable>(_ endpoint: Endpoint, type: T.Type, completion: @escaping (Result<T, NetworkError>)-> Void){
    guard let url = endpoint.url else {
        completion(.failure(.badURL))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let session = URLSession.shared
    let task = session.dataTask(with: url) { data, response, error in
        if error != nil || data == nil {
            completion(.failure(.badClient))
            return
        }
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            completion(.failure(.badServer))
            return
        }

        do {
            let results = try JSONDecoder().decode(type.self, from: data!)
            completion(.success(results))
            
        } catch {
            print("JSON error: \(error.localizedDescription)")
            completion(.failure(.unknown))
        }
    }
    task.resume()
}
enum NetworkError: String, Error{
    case badURL = "Invalid URL!"
    case badClient = "Client error!"
    case badServer = "Server error!"
    case unknown = "JSON error!"
}

// MARK: - struct for API

struct OneCall: Codable {
    var current: Current
    // var hourly:[Hourly]
    var daily: [Daily]
}

struct Weather: Codable {
    var main: String
    var description: String
    // improvement : add var icon String for more image
}

struct Current: Codable {
    var sunrise: Int
    var sunset: Int
    var temp: Double
    var feels_like: Double
    
    var humidity: Int //%
    var uvi: Double //UV Index
    var wind_speed: Double // m/s
    var clouds: Int //%
    var weather: [Weather]
}
//Daily
struct Daily: Codable{
    var humidity: Int
    var temp: Temp
    var dt: Int
}

/*struct Hourly: Codable{
 var dt: Int
 var temp: Double
 var weather:[Weather]
 //var pop: Double       // probability of precipitation
 
 }*/

struct Temp: Codable{
    var min: Double
    var max: Double
    var day: Double
}

//LocationName API
struct name: Codable {
    var name: String
}
//for LocationViewController
struct Coordinates:Codable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
}

struct Endpoint {
    var path: String = "/data/2.5/onecall"
    var queryItems: [URLQueryItem] = [
        URLQueryItem(name: "appid", value: "4858a234b2f80452c562d5ff6787aea6")
    ]
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
}

