//
//  ViewController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 13/4/2022.
//

import UIKit
import CoreLocation
import AVFoundation
import UserNotifications

// allow lock of orientation
// see reference from stackoverflow in about page controller
struct AppUtility {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
   
        self.lockOrientation(orientation)
    
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}

class WeatherRadarViewController: UIViewController, UITextFieldDelegate, WeatherManagerDelegate,
                                  CLLocationManagerDelegate, AVSpeechSynthesizerDelegate, UNUserNotificationCenterDelegate {
   
    // protocol for weather manager delegate if the updating of weather information fails
    func didFailWithError(error: Error) {
        print("in the didfailwitherror method")
        print(error)
        // in order to call the alert box appearing, I need dispatchqueue.main.async
        // this allows the layout engine to not be performed from a background thread and be accessed from the main thread
        DispatchQueue.main.async {
            if self.searchTextField.text == "" {
                print("in the nil section of the error")
            } else {
                self.displayErrorMessage(title: "Error", message: "Can't find city name")
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
    
    // MARK: - Find Location
    // when updating the location infromation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location data")
        // last element in array, get the most accurate location
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeatherLocation(lat: lat, long: lon)
        }
        
    }
    
    // when a location managing has failed
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    // appid=b033f1a6906e208563565acfe60cf05a
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherCondition: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var feelslikeTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    
    
    @IBOutlet weak var celsiusConvertor: UILabel!
    @IBOutlet weak var minCelsiusConvertor: UILabel!
    @IBOutlet weak var maxCelsiusConvertor: UILabel!
    @IBOutlet weak var feelsCelsiusConvertor: UILabel!
    
    // MARK: - Ability to dismiss keyboard from one tap gesture handler when clicking the view
    // to initliase the ability to hide the keyboard
    func initialiseHideKeyboard() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(labelTap)
    }
    
    // ability to dismiss the keyboard
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    // MARK: - ability to convert between celsius and fahrenheit from one tap gesture handler when clicking a label
    // @objc means making the code visible for interaction with objective c
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

            displayList = convertToFahrenheit(temp: self.temperatureLabel.text!, min: self.minTemperatureLabel.text!, max: self.maxTemperatureLabel.text!, feels: self.feelslikeTemperatureLabel.text!)
            self.temperatureLabel.text = displayList[0]
            self.minTemperatureLabel.text = displayList[1]
            self.maxTemperatureLabel.text = displayList[2]
            self.feelslikeTemperatureLabel.text = displayList[3]

        } else {
            self.celsiusConvertor.text = "C"
            self.minCelsiusConvertor.text = "C"
            self.maxCelsiusConvertor.text = "C"
            self.feelsCelsiusConvertor.text = "C"
            
            displayList = convertToCelsius(temp: self.temperatureLabel.text!, min: self.minTemperatureLabel.text!, max: self.maxTemperatureLabel.text!, feels: self.feelslikeTemperatureLabel.text!)
            self.temperatureLabel.text = displayList[0]
            self.minTemperatureLabel.text = displayList[1]
            self.maxTemperatureLabel.text = displayList[2]
            self.feelslikeTemperatureLabel.text = displayList[3]
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
    @IBAction func doubleTapGesture(_ sender: Any) {
        print("double tap activated")
        var speechString = ""
        if self.celsiusConvertor.text == "C" {
            speechString = "The weather today is " + temperatureLabel.text! + " degrees celsius at " + cityLabel.text!
        } else {
            speechString = "The weather today is " + temperatureLabel.text! + " degrees fahrenheit at " + cityLabel.text!
        }
        avSpeechSynthesizer.speak(getUtterance(speechString))
    }
    
    // instance varaible of the WeatherModel structure
    var weatherModel: WeatherModel?
    
    // instance varaible to call the weather manager structure
    var weatherManager = WeatherManager()
    // responsible for getting the current location
    let locationManager = CLLocationManager()
    // create speech object
    let avSpeechSynthesizer = AVSpeechSynthesizer()
    // create notification object
    let notification = UNUserNotificationCenter.current()
    

    // when the search button is pressed and make use to make the view or any subview that is the first responder resign (optionally force)
    @IBAction func searchPressed(_ sender: UIButton) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.endEditing(true)
    }
    
    // returns back to current location
    @IBAction func locationPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    // called when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    

    // when text field is end editing, call fetch weather method and reset textfield
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
//        searchTextField.text = ""
        
    }
    
    // alert button which leads to the heat map
    @IBAction func alertButton(_ sender: Any) {
        
    }
    
    // MARK: - Navigation to the heatmap
    // segue which leads to the heatmap page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "alertSegue" {
            if let weather = weatherModel {
                print("in if alertsegue")
                let destination = segue.destination as! AlertWarningsViewController
                destination.weather = weather
            }
        }
    }
    
    // MARK: - audio speech to text
    // getUtterance is used to convert the weather descirption text into speech for users to hear
    // see reference in about page controller
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
    
    // MARK: - the updating of weather information
    // to update weather whenever a new city is searched
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
//        print(weather.temperature)
        // we need dispatchqueue.main.async because async allows us to execute the update and change of information
        // from the background and rather have the updating of information block and cog up the compiling and running of code
        // from the main thread, avoid our app from crashing and staying frozen and make users assume app has crashed
        DispatchQueue.main.async {
            // assigns the new weather desciription into the labels
            // because it is a closure, we need to use self
            // check what are we converting first into, celsius or fahrenheit
            if self.celsiusConvertor.text == "C" {
                self.temperatureLabel.text = weather.temperatureString
                self.minTemperatureLabel.text = weather.minTemperatureString
                self.maxTemperatureLabel.text = weather.maxTemperatureString
                self.feelslikeTemperatureLabel.text = weather.feelsLikeTemperatureString
            } else {
                var convert = Double(weather.temperatureString)! * 1.8 + 32
                self.temperatureLabel.text = String(format: "%.0f", convert)
                
                convert = Double(weather.minTemperatureString)! * 1.8 + 32
                self.minTemperatureLabel.text = String(format: "%.0f", convert)
                
                convert = Double(weather.maxTemperatureString)! * 1.8 + 32
                self.maxTemperatureLabel.text = String(format: "%.0f", convert)
                
                convert = Double(weather.feelsLikeTemperatureString)! * 1.8 + 32
                self.feelslikeTemperatureLabel.text = String(format: "%.0f", convert)
            }
            self.weatherCondition.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName + ", " + weather.countryName
            self.weatherModel = WeatherModel(conditionId: weather.conditionId, cityName: weather.cityName, temperature: weather.temperature, countryName: weather.countryName, weatherDescription: weather.weatherDescription, lat: weather.lat, lon: weather.lon, min: weather.min, max: weather.max, feelsLike: weather.feelsLike)
            print(self.weatherModel)
            self.weatherDescription.text = weather.weatherDescription
            
            // notification content
            // this sends a notification to users depending on the weather forecast that appears on the screen
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Weather Alert"
            print(self.weatherModel?.temperature)
            if self.weatherModel?.conditionId == 800 && self.weatherModel!.temperature >= 30 {
                notificationContent.body = "It is sunny outside in " + self.weatherModel!.cityName + ". Make sure to wear sunscreen"
            } else if self.weatherModel!.conditionId >= 500 && self.weatherModel!.conditionId <= 531 {
                notificationContent.body = "It is raining outside in " + self.weatherModel!.cityName + ". Make sure to wear a rain jacket or bring an umbrella"
            } else if self.weatherModel!.conditionId >= 600 && self.weatherModel!.conditionId <= 622 {
                notificationContent.body = "It is snowing outside in " + self.weatherModel!.cityName + ". Make sure to wear thermal clothing"
            } else if self.weatherModel!.conditionId >= 200 && self.weatherModel!.conditionId <= 232 {
                notificationContent.body = "Thunderstorm expected in " + self.weatherModel!.cityName + ". Stay inside if possible"
            } else if self.weatherModel?.conditionId == 731 {
                notificationContent.body = "Thunderstorm expected in " + self.weatherModel!.cityName + ". Please evacuate or stay inside if possible"
            } else if self.weatherModel?.conditionId == 762 {
                notificationContent.body = "Volcanic ash expected in " + self.weatherModel!.cityName + ". Please evacuate or stay inside if possible"
            } else if self.weatherModel?.conditionId == 781 {
                notificationContent.body = "Tornado expected in " + self.weatherModel!.cityName + ". Please evacuate or stay inside if possible"
            } else {
                notificationContent.body = "No warnings today in " + self.weatherModel!.cityName + ". Have a Great Day!"
            }
            
            // comes after 3 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            // use UUID().uuidString because it always returns a unique string identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            UNUserNotificationCenter.current().delegate = self
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // swipe up function allows users to be able to have the gesture ability to swipe up and view the about page
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction(gesture:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        // set up the ability to do one tap gesture of hide keyboard
        initialiseHideKeyboard()
        
        // delegations
        // set the delegate to self
        // this means it equals to the current class (weatherradarviewcontroller)
        // helps us be notified such as when the text field is being interacted
        searchTextField.delegate = self
        weatherManager.delegate = self
        avSpeechSynthesizer.delegate = self
        
        locationManager.delegate = self
        // trigger a permission request for getting user location
        locationManager.requestWhenInUseAuthorization()
        // to use the location manager to request location
        locationManager.requestLocation()

        // enable the ability to convert temperature
        self.setupConvertorTap()
        
        notification.delegate = self
        // check if we have been given permission to send local notifcations
        notification.requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            } else {
                print("permission granted")
            }
        }
        // locks the orientation to potratit only
        AppUtility.lockOrientation(.portrait)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // reset back to only all orientations
        AppUtility.lockOrientation(.all)
    }
    
    // MARK: - swipe up gesture handler for viewing the about page
    // swipeUpAction checks if the gesture is swipe up, about page appears
    @objc func swipeUpAction(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up {
            print("swiping up")
            performSegue(withIdentifier: "aboutSegue", sender: self)
        }
    }

    // MARK: - to allow local notifications to be viewed when using the app
    // method allows us to see a banner notification appear on the screen, without it, notification would not appear as it would be on the default setting of .none
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return .banner
    }

}

