import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchInput: UITextField!
    
    var weatherManager = WeatherManager()
    let location = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location.delegate = self
        weatherManager.delegate = self
        searchInput.delegate = self
        
        location.requestWhenInUseAuthorization()
        location.requestLocation()
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        location.requestLocation()
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchInput.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchInput.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (searchInput.text != "") {
            return true
        }
        else {
            searchInput.placeholder = "Type something here!"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchInput.text {
            weatherManager.fetchWeather(location: city)
        }
        searchInput.text = ""
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.city
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
        }
    }
    
    func didErrorWeather(_ error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationResult = locations.last {
            location.stopUpdatingLocation()
            let lat = locationResult.coordinate.latitude
            let lon = locationResult.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}
