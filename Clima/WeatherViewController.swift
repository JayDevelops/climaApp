//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//

import UIKit
import CoreLocation

//Importing the pod libraries
import Alamofire
import SwiftyJSON

//Conforms to the rule of the CLLocationManagerDelegate
class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate  {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d10676a6f254ed117a81173968b8c0bb"

    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        
        //Sets up the location manager accuracy location for the user
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //Requests the user for their location
        locationManager.requestWhenInUseAuthorization()
        
        //Starts looking for the location for the iPhone, its an asynchronous method
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, paramaters: [String: String]) {
        
        AF.request(url, method: .get, parameters: paramaters).responseJSON { (response) in
            if (response.value != nil) {
                print("Sucess! Got the Weather Data which we need!")
                
                let weatherJSON : JSON = JSON(response.value)
                self.updateWeatherData(json: weatherJSON)
            }   else    {
                print("Error: \(String(describing: response.value)) has nothing in it")
                self.cityLabel.text = "There are connection issues, please try again..."
            }
        }
        
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateWeatherData (json : JSON )   {
        
        //That .double changes to a double
        if let tempResult = json["main"]["temp"].double {
        
        let tempCalculation = round(tempResult * (9/5) - 459.67)
        
        weatherDataModel.temperature = Int(tempCalculation)
        
        //Changes the weather city to a string
        weatherDataModel.city = json["name"].stringValue
        
        //Gets the condition and updates the object
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        //Updates the weather icon name from a method from the model
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        //Call the method of the the weather data
        updateUIWithWeatherData()
            
        }   else    {
            
            cityLabel.text = "Weather Unaivailable :("
        }
        
    }
    
    
    //Write the updateWeatherData method here:
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData()  {
        cityLabel.text = weatherDataModel.city
        
        temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        //Stop the location as soon as you get a valid result
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longtitude = String(location.coordinate.longitude)
            
            let params : [String : String] = [ "lat" : latitude, "lon" : longtitude, "appid" : APP_ID ]
            
            getWeatherData(url: WEATHER_URL, paramaters: params)
        }

    }
    
    
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)   {
        print(error)
        cityLabel.text = "Location Unaivalable"
        
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, paramaters: params)
        
    }
    
    
    
    
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
      
            destinationVC.delegate = self
        }
        
    }
    
}


