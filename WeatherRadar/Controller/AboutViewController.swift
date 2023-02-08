//
//  AboutViewController.swift
//  WeatherRadar
//
//  Created by Ethan Fang on 6/6/2022.
//

import UIKit

class AboutViewController: UIViewController {

    // text view variables to display the acknowledgments
    @IBOutlet weak var thirdPartyText: UITextView!
    @IBOutlet weak var referencesOnlineText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // edit the textviews to display information when about page is loaded
        thirdPartyText.text = """
                            This app utilises data provided by OpenWeatherAPI https://openweathermap.org/api
                            
                            Google Maps SDK for iOS Utility Library. Version 4.1.0. Pods Version 12.0. (2022, May 31). GitHub. https://github.com/googlemaps/google-maps-ios-utils
                            Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/
                            Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.
                            """
        referencesOnlineText.text = """
                            Chow, M. (2022, February 1). Swift Text-To-Speech As Deep As Possible. Medium. https://itnext.io/swift-avfoundation-framework-text-to-speech-tool-f3e3bfc7ecf7
                            
                            Heatmaps | Maps SDK for iOS. (n.d.). Google Developers. https://developers.google.com/maps/documentation/ios-sdk/utility/heatmap
                            
                            Adelmaer, A. (2019, August 6). How To Add a Tap Gesture to UILabel in Xcode (Swift). AppMakers.DEV. https://medium.com/app-makers/how-to-add-a-tap-gesture-to-uilabel-in-xcode-swift-7ada58f1664
                            
                            uiviewcontroller - How to lock orientation of one view controller to portrait mode only in Swift. (n.d.). Stack Overflow. Retrieved June 6, 2022, from https://stackoverflow.com/questions/28938660/how-to-lock-orientation-of-one-view-controller-to-portrait-mode-only-in-swift

                            """
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
