//
//  FavouriteWeather+CoreDataProperties.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 6/6/2022.
//
//

import Foundation
import CoreData


extension FavouriteWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteWeather> {
        return NSFetchRequest<FavouriteWeather>(entityName: "FavouriteWeather")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var countryName: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var temperature: Double
    @NSManaged public var weatherDesc: String?
    @NSManaged public var weatherIcon: Int32
    @NSManaged public var temp_max: Double
    @NSManaged public var temp_min: Double
    @NSManaged public var feels_like: Double

}

extension FavouriteWeather : Identifiable {

}
