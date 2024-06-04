import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didErrorWeather(_ error: Error)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    var apiKey: String = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
    var weatherURL: String { "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
    }
    
    func fetchWeather(location: String) {
        let urlString = "\(weatherURL)&q=\(location)"
        performRequest(urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if (error != nil) {
                    delegate?.didErrorWeather(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let city = decodedData.name
            let temp = decodedData.main.temp
            return WeatherModel(city: city, conditionId: id, temperature: temp)
        }
        catch {
            delegate?.didErrorWeather(error)
            return nil
        }
    }
    
    
}
