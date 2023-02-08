//
//  WeatherManager.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 17/4/2022.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    // weather api url
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b033f1a6906e208563565acfe60cf05a&units=metric"
    
    var delegate: WeatherManagerDelegate?

    // method to return the url
    func returnUrl(cityName: String) -> String{
        var city = cityName
        if let index = city.firstIndex(of: " ") {
           city = city.replacingOccurrences(of: " ", with: "%20")
        }
        let urlString = "\(weatherURL)&q=\(city)"
        return urlString
    }
    
    // method to fetch the weather through city name
    func fetchWeather(cityName: String) {
        var city = cityName
        if let index = city.firstIndex(of: " ") {
           city = city.replacingOccurrences(of: " ", with: "%20")
        }
        let urlString = "\(weatherURL)&q=\(city)"
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    // method to fetch the weather through coordinates
    func fetchWeatherLocation(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(long)"
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    // perforRequest function is to perform netowrking where we
    // perform the request to the web server api from our application to get a response back to the app
    func performRequest(urlString: String){
        // create a url object
        if let url = URL(string: urlString) {
            // create url session to be doing our networking
            let session = URLSession(configuration: .default)
            // give the url session a task (in this situation, fetching the data from our url)
            let task = session.dataTask(with: url) { (data, response, error) in
                // checks if information has any error in the process
                if error != nil {
                    print(error!)
                    return
                }
                // check what data we got back
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
//                        print(weather)
                        // delegate is used to send the weather data to the receving method which is any method that adopts the protocol
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // start the task, use resume because task can be suspended and a new task begins in a suspended state
            task.resume()
        }
    }
    
    // 
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        // decode json
        let decoder = JSONDecoder()
        // do catch method is used in case there's an error occur if decode fails
        do {
            // first param is what you want to decode, .self turns it into a data type
            // second param is the decodable data type that conforms to the protocol
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
//            print(decodedData)
            // assign json values to local var
            // need to define in weatherdata file since decodedDara is a weatherdata type
            let id = decodedData.weather[0].id
            
            let temp = decodedData.main.temp
            let min = decodedData.main.temp_min
            let max = decodedData.main.temp_max
            let feelsLike = decodedData.main.feels_like

            let name = decodedData.name
            let country = decodedData.sys.country
            let desc = decodedData.weather[0].description
           
            let lat = decodedData.coord.lat
            let lon = decodedData.coord.lon
            

            print(id)
            print(temp)
            print(name)
            print(country)
            print(desc)
            print(lat)
            print(lon)
            
            // create a weathermodel instance
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, countryName: country, weatherDescription: desc, lat: lat, lon: lon, min: min, max: max, feelsLike: feelsLike)
            return weather

        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

}
