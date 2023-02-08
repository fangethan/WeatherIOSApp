//
//  AddFavouritesTableViewController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 17/4/2022.
//

import UIKit

// allows us to call the apiservice and retrieve the information
struct WeatherResponse: Codable {
    var coord: WeatherCoord
    var weather: [WeatherDescription]
    var name: String
    var sys: WeatherSystem
    var main: WeatherMain
}

struct WeatherCoord: Codable {
    var lon: Double
    var lat: Double
}

struct WeatherDescription: Codable {
    var id: Int
    var description: String
}

struct WeatherSystem: Codable {
    var country: String
}

struct WeatherMain: Codable {
    var temp: Double
    var temp_min: Double
    var temp_max: Double
    var feels_like: Double
}

enum WeatherListError: Error {
    case invalidServerResponse
}

struct WeatherDetails: Decodable {
    var type: String
    var icon: Int
    var desc: String
}


class AddFavouritesTableViewController: UITableViewController, UISearchBarDelegate {

    // instance varaible of the weather manager structure
    var weatherManager = WeatherManager()
    
    // for the table view
    let WEATHER_CELL = "weatherCell"
    
    // weak keyword is needed to prevent strong reference cycles
    weak var databaseController: DatabaseProtocol?

    // weather url to be called
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b033f1a6906e208563565acfe60cf05a&units=metric"
    // the weather to be found
    var newWeather = [WeatherModel]()
    // searching/loading indicator
    var indicator = UIActivityIndicatorView()
    
    // MARK: - decode the information depending on the request given in the search
    // where we call the api
    // async tells program that we are expecting this method to execute asynchronously
    func requestWeatherNamed(_ weatherName: String) async {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
                databaseController = appDelegate?.databaseController
        
        // get the requested url
        let requestURL = URL(string: weatherManager.returnUrl(cityName: weatherName))
        // check if requestURL is not nil
        if let requestURL = requestURL {
            Task {
                // make sure the httpresponse is not invalid
                do {
                    let (data, response) = try await URLSession.shared.data(from: requestURL)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw WeatherListError.invalidServerResponse
                    }
                    // we decode the information from the api into json format
                    let decoder = JSONDecoder()
                    let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                    // for testing purposes to see if we retireved all the correct information
                    print("weatherResponse data")
                    print(weatherResponse.name)
                    print(weatherResponse.coord.lat)
                    print(weatherResponse.coord.lon)
                    
                    print(weatherResponse.weather[0].id)
                    print(weatherResponse.weather[0].description)
                    
                    print(weatherResponse.main.temp)
                    print(weatherResponse.main.temp_min)
                    print(weatherResponse.main.temp_max)
                    print(weatherResponse.main.feels_like)
                    
                    print(weatherResponse.sys.country)
                    // store it in a weathermodel constructor variable
                    var weatherModel = WeatherModel(conditionId: weatherResponse.weather[0].id, cityName: weatherResponse.name, temperature: weatherResponse.main.temp, countryName: weatherResponse.sys.country, weatherDescription: weatherResponse.weather[0].description, lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon, min: weatherResponse.main.temp_min, max: weatherResponse.main.temp_max, feelsLike: weatherResponse.main.feels_like)
                    // added to the newWeather list
                    newWeather.append(weatherModel)
                    // reload table
                    tableView.reloadData()
                    // stop loading
                    indicator.stopAnimating()
                    
                }
                catch {
                    // error if nothing was found with an error message appearing on screen
                    print(" Caught Error: " + error.localizedDescription)
                    if weatherName == "" {
                        print("in the nil section of the catch phase")
                    } else {
                        displayErrorMessage(title: "Error", message: "No city found. Try again")
                    }
                    indicator.stopAnimating()
                }
                
            }
        }
    }
    
    // MARK: - validation in case city name cannot be found
    // display error message on the screen
    func displayErrorMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message,
         preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // called if the search hits enter or taps the search button after typing in search field
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // clear list and refresh tabeleview at the beginning
        newWeather.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        // call the search function to find city
        // the await keyword is used to say that the code will stop executing at this point in the method and await a response from the data task
        // task is used since requestWeatherNamed is async
        // async method allows you to do multiple things at the same time
        // we use async due to we are waiting for information to be received from the I/O work from reading the json data from the api
        Task {
         await requestWeatherNamed(searchText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create the UISearchController and assign it to the view controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController

        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
            view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
            view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newWeather.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WEATHER_CELL, for: indexPath)
       
        var content = cell.defaultContentConfiguration()
        let weather = newWeather[indexPath.row]
        content.text = weather.cityName
        content.secondaryText = weather.countryName
        cell.contentConfiguration = content
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when row is selected, assign it to clicked weather
        let clickedWeather = newWeather[indexPath.row]
        // where we then store the information into the databasecontroller and the new city is stored in the favourites weather page
        let _ = databaseController?.addWeather(cityName: clickedWeather.cityName, countryName: clickedWeather.countryName, lat: clickedWeather.lat, lon: clickedWeather.lon, temperature: clickedWeather.temperature, weatherDesc: clickedWeather.weatherDescription, weatherIcon: Int32(clickedWeather.conditionId), min: clickedWeather.min, max: clickedWeather.max, feelsLike: clickedWeather.feelsLike)
        navigationController?.popViewController(animated: true)
    }


    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
