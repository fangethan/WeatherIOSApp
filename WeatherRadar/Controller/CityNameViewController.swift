//
//  CityNameViewController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 17/4/2022.
//

import UIKit
import AVFoundation

class CityNameViewController: UIViewController, AVSpeechSynthesizerDelegate, WeatherManagerDelegate {
    // if fetch weather fails
    func didFailWithError(error: Error) {
        print("in the didfailwitherror method")
        print(error)
    }
    
    
    // variables
    var favouriteList: FavouriteWeather?
    weak var databaseController: DatabaseProtocol?
    let avSpeechSynthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionIcon: UIImageView!
    
    
    @IBOutlet weak var descirption: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var feelsTemperatureLabel: UILabel!
    
    @IBOutlet weak var celsiusConvertor: UILabel!
    @IBOutlet weak var minCelsiusConvertor: UILabel!
    @IBOutlet weak var maxCelsiusConvertor: UILabel!
    @IBOutlet weak var feelsCelsiusConvertor: UILabel!
    
    
    @IBAction func alertButton(_ sender: Any) {
    }
    
    // MARK: - single tap gesture handler for converting from celsius to fahreneit or vice versa
    // label tapped is the method to convert the temperature from celsius to fahreneit or vice versa
    // see reference in about page controller 
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        print("celsuis convertor has been tapped")
        var displayList: [String] = []
        if self.celsiusConvertor.text == "C" {
            self.celsiusConvertor.text = "F"
            self.minCelsiusConvertor.text = "F"
            self.maxCelsiusConvertor.text = "F"
            self.feelsCelsiusConvertor.text = "F"

            displayList = convertToFahrenheit(temp: self.temperatureLabel.text!, min: self.minTemperatureLabel.text!, max: self.maxTemperatureLabel.text!, feels: self.feelsTemperatureLabel.text!)
            self.temperatureLabel.text = displayList[0]
            self.minTemperatureLabel.text = displayList[1]
            self.maxTemperatureLabel.text = displayList[2]
            self.feelsTemperatureLabel.text = displayList[3]

        } else {
            self.celsiusConvertor.text = "C"
            self.minCelsiusConvertor.text = "C"
            self.maxCelsiusConvertor.text = "C"
            self.feelsCelsiusConvertor.text = "C"
            
            displayList = convertToCelsius(temp: self.temperatureLabel.text!, min: self.minTemperatureLabel.text!, max: self.maxTemperatureLabel.text!, feels: self.feelsTemperatureLabel.text!)
            self.temperatureLabel.text = displayList[0]
            self.minTemperatureLabel.text = displayList[1]
            self.maxTemperatureLabel.text = displayList[2]
            self.feelsTemperatureLabel.text = displayList[3]
        }
        
    }
    
    // setupConvertorTap is to allow the user to be able to tap on the label C or F to allow conversion between temperatures
    func setupConvertorTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.celsiusConvertor.isUserInteractionEnabled = true
        self.celsiusConvertor.addGestureRecognizer(labelTap)
    }
    
    // method to convert from celsius to fahrenheit
    func convertToFahrenheit(temp: String, min: String, max: String, feels: String) -> [String]{
        var temp = Double(temp)! * 1.8 + 32
        var min = Double(min)! * 1.8 + 32
        var max = Double(max)! * 1.8 + 32
        var feels = Double(feels)! * 1.8 + 32
        
        var convertedList: [String] = [String(format: "%.0f", temp), String(format: "%.0f", min), String(format: "%.0f", max), String(format: "%.0f", feels)]
        return convertedList
    }
    
    // method to convert from fahrenheit to celsius
    func convertToCelsius(temp: String, min: String, max: String, feels: String) -> [String]{
        var temp = (Double(temp)! - 32) / 1.8
        var min = (Double(min)! - 32) / 1.8
        var max = (Double(max)! - 32) / 1.8
        var feels = (Double(feels)! - 32) / 1.8
        
        var convertedList: [String] = [String(format: "%.0f", temp), String(format: "%.0f", min), String(format: "%.0f", max), String(format: "%.0f", feels)]
        return convertedList
    }
    
    // MARK: - double tap gesture handler for playing audio
    // audio activated from gesture handler of a double tap
    // see reference in about page controller
    @IBAction func doubleTapGesture(_ sender: Any) {
        var speechString = ""
        if self.celsiusConvertor.text == "C" {
            speechString = "The weather today is " + temperatureLabel.text! + " degrees celsius at " + cityName.text!
        } else {
            speechString = "The weather today is " + temperatureLabel.text! + " degrees fahrenheit at " + cityName.text!
        }
        avSpeechSynthesizer.speak(getUtterance(speechString))
    }
    
    // MARK: - audio for text to speech
    // getUtterance is used to convert the weather descirption text into speech for users to hear
    func getUtterance(_ speechString: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: speechString)
        // language spoken
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        // speed of speech
        utterance.rate = 0.5
        // how sharp each word is going to be pronounced
        utterance.pitchMultiplier = 1.0
        // volume of speech
        utterance.volume = 0.5
        // time delay before starting the current speech
        utterance.preUtteranceDelay = TimeInterval.init(exactly: 1)!
        utterance.postUtteranceDelay = TimeInterval.init(exactly: 2)!
        return utterance
    }
    
    // weather manager instance
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        avSpeechSynthesizer.delegate = self
        weatherManager.delegate = self

        // enable the ability to convert temperature
        self.setupConvertorTap()
        
        // checks if favourite weather list is not nil
        // if it is not nill, call fetch weather to update
        if let favouriteList = favouriteList {
            weatherManager.fetchWeather(cityName: favouriteList.cityName!)
        }
        
        // locks the orientation to potratit only
        AppUtility.lockOrientation(.portrait)

        // Do any additional setup after loading the view.
    }
    
    // update weather
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityName.text = weather.cityName + ", " + weather.countryName
            self.temperatureLabel.text = weather.temperatureString
            self.conditionIcon.image = UIImage(systemName: weather.conditionName)
            self.minTemperatureLabel.text = weather.minTemperatureString
            self.maxTemperatureLabel.text = weather.maxTemperatureString
            self.feelsTemperatureLabel.text = weather.feelsLikeTemperatureString
        }
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset back to only all orientations
        AppUtility.lockOrientation(.all)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        // segue which leads to the heatmap page
        if segue.identifier == "cityAlertSegue" {
            if let favouriteList = favouriteList {
                var weatherInfo = WeatherModel(conditionId: Int(favouriteList.weatherIcon), cityName: favouriteList.cityName!, temperature: favouriteList.temperature, countryName: favouriteList.countryName!, weatherDescription: favouriteList.weatherDesc!, lat: favouriteList.lat, lon: favouriteList.lon, min: favouriteList.temp_min, max: favouriteList.temp_max, feelsLike: favouriteList.feels_like)
                let destination = segue.destination as! AlertWarningsViewController
                destination.weather = weatherInfo
            }
        }
    }
    

}
