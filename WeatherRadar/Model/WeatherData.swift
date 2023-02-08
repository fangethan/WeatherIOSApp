//
//  WeatherData.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 18/4/2022.
//

import Foundation

// structure the weather data is coming back in from the api 
// decoder is used to decode a type from an external representation
// in this situation it is the json representation

struct WeatherData: Codable {
    let name: String
    let sys: System
    let main: Main
    let weather: [Weather]
    let coord: Coordinate
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}


struct System: Codable {
    let country: String
}

struct Main: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let feels_like: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}




