//
//  ViewController.swift
//  Cocoapods
//
//  Created by Danyil ZBOROVKYI on 7/3/19.
//  Copyright © 2019 Danyil ZBOROVKYI. All rights reserved.
//

import UIKit
import Foundation
import RecastAI
import ForecastIO

class ViewController: UIViewController {
    var bot: RecastAIClient?
    var client: DarkSkyClient?
    let RECAST_TOKEN = "1613178de1ab1c5d248d6489392c0261"
    let DARKSKY_TOKEN = "e3be133c71bf4d2bfca68fcec16e0772"

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bot = RecastAIClient(token : RECAST_TOKEN, language: "en")
        self.client = DarkSkyClient(apiKey: DARKSKY_TOKEN)
    }
    
    //Keyboard appear at display
    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    
    @IBAction func sendEnter(_ sender: UITextField) {
        if let textField = sender.text {
            if textField.isEmpty {
                print("Enter location")
                self.resultLabel.text = "Enter location"
            } else {
                makeRequest(request: textField)
            }
        }
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        if let textField = textField.text {
            if textField.isEmpty {
                print("Enter location")
                self.resultLabel.text = "Enter location"
            } else {
                makeRequest(request: textField)
            }
        }
    }
    
    //Make text request to Recast.AI API
    func makeRequest(request: String) {
        self.bot?.textRequest(request, successHandler: successHandler, failureHandle: failureHandle)
    }
    
    func successHandler(_ response: Response) {
        //print("response: \(response)")
        
        if let location = response.get(entity: "location") {
            //print(location)
            //resultLabel.text = "Location found : \(location["raw"]!)"
            requestForecast(location: location["raw"] as! String, lat: location["lat"] as! Double, lng: location["lng"] as! Double)
        }
        else {
            DispatchQueue.main.async {
                self.resultLabel.text = "Sorry, I dont know this location"
            }
        }
    }
    
    func failureHandle(_ err: Error) {
        DispatchQueue.main.async {
            print("processError : \(err)")
            self.resultLabel.text = "Error"
        }
    }
    
    //Make request to Forecast
    func requestForecast(location: String, lat: Double, lng: Double) {
        client!.units = .si
        client!.language = .english
        
        client?.getForecast(latitude: lat, longitude: lng, completion: { (result) in
            DispatchQueue.main.async {
            switch result {
            case .success(let current, let request):
                print("meta request: \(request)")
                let city = "🗺 Location: " + location.capitalizingFirstLetter() + "\n" + "\n"
                let summary = "🌍 Summary: " + (current.currently?.summary)! + "\n" + "\n"
                let temperature = "🌡 Current temperature: " + String(describing: Int((current.currently?.temperature)!)) + " °C"
                let resultString = city + summary + temperature
                
                self.resultLabel.text = resultString
            case .failure(let error):
                print("ERROR: \(error)")
                self.resultLabel.text = "Error! Look at console."
            }
            
            //print(result)
            }
        })
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
