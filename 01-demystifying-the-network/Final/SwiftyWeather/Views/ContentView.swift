/// Copyright (c) 2023 Kodeco Inc.
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
import CoreLocationUI
import SwiftUI

struct ContentView: View {
  @State private var searchText = ""
  @State private var errorMessage: String?

  private var weatherViewModel = WeatherViewModel()

  var body: some View {
    NavigationStack {
      if let topResponse = weatherViewModel.topResponse {
        VStack {
          WeatherIconView(iconString: topResponse.weatherConditions[0].iconString)
          Text(topResponse.name)
            .font(.title)
          Text(topResponse.temperatureData.current.formattedTemp)
            .font(.largeTitle)
          Text(topResponse.weatherConditions.first?.categoryDescription.capitalized ?? "")
            .font(.title3)
          HStack {
            Text("H: \(topResponse.temperatureData.high.formattedTemp)")
              .font(.headline)
            Text("L: \(topResponse.temperatureData.low.formattedTemp)")
              .font(.headline)
          }
        }
      } else {
        if weatherViewModel.isSearching {
          ProgressView()
        } else {
          VStack {
            ContentUnavailableView(
              errorMessage ?? "Please type a city above and press enter",
              systemImage: "magnifyingglass"
            )
          }
        }
      }
    }
    .searchable(text: $searchText, prompt: Text("City Name"))
    .onSubmit(of: .search) {
      weatherViewModel.topResponse = nil
      weatherViewModel.fetchWeather(for: searchText)
    }
    .onChange(of: weatherViewModel.errorMessage) { oldValue, newValue in
      guard oldValue != newValue else {
        return
      }
      self.errorMessage = newValue
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
