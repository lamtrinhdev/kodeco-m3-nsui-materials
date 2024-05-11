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

import Foundation

/// A concrete implementation of `WeatherFetchable` that is responsible for fetching weather data.
final class NetworkService: WeatherFetchable {
  private let urlSession: URLSession

  /// Creates a `NetworkService` instance.
  /// - Parameter urlSession: The `URLSession` object responsible for performing the fetched. Defaults to the `shared` instance.
  init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }

  func fetchWeather(for cityName: String, completion: @escaping (Result<TopResponse, NetworkError>) -> Void) {
    guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=imperial&appid=e67bbf9e8daa3100274782b4238ff26d") else {
      completion(.failure(.invalidURL))
      return
    }
    urlSession.dataTask(with: url) { data, response, _ in
      DispatchQueue.main.async {
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
          completion(.failure(NetworkError.invalidResponse))
          return
        }
        guard let data else {
          completion(.failure(.noData))
          return
        }
        do {
          let topResponse = try JSONDecoder().decode(TopResponse.self, from: data)
          completion(.success(topResponse))
        } catch DecodingError.keyNotFound(let key, let context) {
          completion(
            .failure(
              .decodeError(
                message: "Could not find key \(key) in JSON: \(context.debugDescription)",
                error: nil
              )
            )
          )
        } catch DecodingError.valueNotFound(let type, let context) {
          completion(
            .failure(
              .decodeError(
                message: "Could not find type \(type) in JSON: \(context.debugDescription)",
                error: nil
              )
            )
          )
        } catch DecodingError.typeMismatch(let type, let context) {
          completion(
            .failure(
              .decodeError(
                message: "Type mismatch for type \(type) in JSON: \(context.debugDescription)",
                error: nil
              )
            )
          )
        } catch DecodingError.dataCorrupted(let context) {
          completion(
            .failure(
              .decodeError(
                message: "Data found to be corrupted in JSON: \(context.debugDescription)",
                error: nil
              )
            )
          )
        } catch {
          completion(.failure(.decodeError(message: "Generic Decoding Error", error: error)))
        }
      }
    }
    .resume()
  }
}
