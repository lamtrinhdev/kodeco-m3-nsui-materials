/// Copyright (c) 2024 Kodeco Inc.
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreLocation
import Foundation

/// The object responsible for updating the view once the data has been fetched.
@Observable
final class WeatherViewModel {
  private var networkService: WeatherFetchable

  /// The core model object bound to the view.
  var topResponse: TopResponse?

  /// Contains any error message that comes up from fetching data.
  var errorMessage: String?

  /// Weather or not the app is currently searching for weather data.
  var isSearching = false

  /// Creates a new instance of the `WeatherViewModel`.
  /// - Parameter networkService: The object responsible for fetching the data. Defaults to a new instance of `NetworkService`.
  init(networkService: WeatherFetchable = NetworkService()) {
    self.networkService = networkService
  }

  ///  Responsible for making use of the network service to perform the fetch.
  /// - Parameter cityName: The name of the city being fetched.
  func fetchWeather(for cityName: String) {
    isSearching.toggle()
    networkService.fetchWeather(for: cityName) { [weak self] result in
      guard let self else { return }
      switch result {
      case .success(let topResponse):
        self.topResponse = topResponse
        self.isSearching.toggle()
      case .failure(let error):
        switch error {
        case .decodeError(let message, _):
          self.errorMessage = "\(message)"
        case .invalidResponse:
          self.errorMessage = "Invalid City Name"
        case .invalidURL:
          self.errorMessage = "Invalid URL"
        case .noData:
          self.errorMessage = "No data"
        }
        self.isSearching.toggle()
      }
    }
  }
}
