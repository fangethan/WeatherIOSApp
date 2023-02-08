//
//  WeatherModel.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 18/4/2022.
//

import Foundation

// weather model shows the data model of the weather elements 
struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    var countryName: String
    var weatherDescription: String
    var lat: Double
    var lon: Double
    var min: Double
    var max: Double
    var feelsLike: Double
    
    // format the temperature into 0 decimal place
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    // format the minimium temperature into 0 decimal place
    var minTemperatureString: String {
        return String(format: "%.0f", min)
    }
    
    // format the maximum temperature into 0 decimal place
    var maxTemperatureString: String {
        return String(format: "%.0f", max)
    }
    
    // format the feels like temperature into 0 decimal place
    var feelsLikeTemperatureString: String {
        return String(format: "%.0f", feelsLike)
    }
    
    // var is used as a computed property where the weather object where it will figrure it out
    // check what the weather condition is by the weather id
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
}
