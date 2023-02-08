//
//  DatabaseProtocol.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 7/5/2022.
//

import Foundation

// define what type of change has been done to the database
enum DatabaseChange {
    case add
    case remove
    case update
}

// protocol defines the delegate we will be using for receiving messages from the database
// the function is to show when a change to any of the weather cities has occured
protocol DatabaseListener: AnyObject {
    func onWeatherListChange(change: DatabaseChange, weatherList: [FavouriteWeather])
}

// protocol defines all the behaviour that a database must have
protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addWeather(cityName: String, countryName: String, lat: Double, lon: Double, temperature: Double, weatherDesc: String, weatherIcon: Int32, min: Double, max: Double, feelsLike: Double) -> FavouriteWeather
    func removeWeather(weather: FavouriteWeather)
}
