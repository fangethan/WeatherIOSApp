//
//  CoreDataController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 7/5/2022.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    // holds all the listeners added to the database inside of the multicast delegate class
    // multicast is used as a generic wrapper around yet another delegate protocol, that means it create one-to-many delegate relationships. This allows providing an object with an array of delegates
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allWeatherFetchedResultsController: NSFetchedResultsController<FavouriteWeather>?
    
    override init() {
        // initialise the persistent container property we are using in the data model
        persistentContainer = NSPersistentContainer(name: "WeatherRadar-DataModel")
        // loads tge core data stack and provides a closure for error handling
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
        if fetchAllWeathers().count == 0 {
//            createDefaultWeather()
            print("nothing in favourite list")
        }

    }
    
    // method will check to see if there are changes to be saved inside of the view context and then save
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
             do {
                 try persistentContainer.viewContext.save()
             } catch {
                 fatalError("Failed to save changes to Core Data with error: \(error)")
             }
         }
    }
    
    // adds the new database listener to the list of listeners
    // provide the listener with initial immediate results depending on what type of listener it is 
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onWeatherListChange(change: .update, weatherList: fetchAllWeathers())
    
    }
    
    // passes the specified listner to the multicast delegate class which then removes it from the set of saved listeners
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // adding weather to favourites list
    func addWeather(cityName: String, countryName: String, lat: Double, lon: Double, temperature: Double, weatherDesc: String, weatherIcon: Int32, min: Double, max: Double, feelsLike: Double) -> FavouriteWeather {
        let weather = NSEntityDescription.insertNewObject(forEntityName:
         "FavouriteWeather", into: persistentContainer.viewContext) as! FavouriteWeather
        
        weather.cityName = cityName
        weather.countryName = countryName
        weather.lat = lat
        weather.lon = lon
        weather.temperature = temperature
        weather.weatherDesc = weatherDesc
        weather.weatherIcon = weatherIcon
        weather.temp_min = min
        weather.temp_max = max
        weather.feels_like = feelsLike

         return weather
    }
    
    // remove weather from favourite weather list
    func removeWeather(weather: FavouriteWeather) {
        print(weather)
        persistentContainer.viewContext.delete(weather)
        print("item has been deleted")
    }
    
    // retrieve all weather
    func fetchAllWeathers() -> [FavouriteWeather] {
        if allWeatherFetchedResultsController == nil {
         // Do something
            let request: NSFetchRequest<FavouriteWeather> = FavouriteWeather.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "cityName", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allWeatherFetchedResultsController = NSFetchedResultsController<FavouriteWeather>(fetchRequest: request,
             managedObjectContext: persistentContainer.viewContext,
             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allWeatherFetchedResultsController?.delegate = self
            
            //perform fetch request
            do {
             try allWeatherFetchedResultsController?.performFetch()
            } catch {
             print("Fetch Request Failed: \(error)")
            }
         }

         if let weathers = allWeatherFetchedResultsController?.fetchedObjects {
             return weathers
         }
         return [FavouriteWeather]()
//        var weathers = [FavouriteWeather]()
//
//         let request: NSFetchRequest<FavouriteWeather> = FavouriteWeather.fetchRequest()
//
//         do {
//             try weathers = persistentContainer.viewContext.fetch(request)
//         } catch {
//             print("Fetch Request failed with error: \(error)")
//         }
//
//         return weathers
    }
    
    // called whenever the fetchedresultscontroller detects a change to the result of its fetch
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if controller == allWeatherFetchedResultsController {
                listeners.invoke() { listener in
                    listener.onWeatherListChange(change: .update, weatherList: fetchAllWeathers())
                    
                }
         }
    }
    
    // testing purpose
//    func createDefaultWeather() {
//        let _ = addWeather(cityName: "Sydney", countryName: "Australia", lat: 123.2, lon: 123.3, temperature: 22.4, weatherDesc: "sunny", weatherIcon: 800)
//        let _ = addWeather(cityName: "Adealide", countryName: "Australia", lat: 123.2, lon: 123.3, temperature: 22.4, weatherDesc: "sunny", weatherIcon: 800)
//        let _ = addWeather(cityName: "Brisbane", countryName: "Australia", lat: 123.2, lon: 123.3, temperature: 22.4, weatherDesc: "sunny", weatherIcon: 800)
//    }
    
}
