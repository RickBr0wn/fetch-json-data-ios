//
//  ContentView.swift
//  fetch-json-data
//
//  Created by Rick Brown on 25/11/2020.
//

import SwiftUI

struct Response: Codable {
  var results: [Result]
}

struct Result: Codable {
  var trackId: Int
  var trackName: String
  var collectionName: String
}

struct ContentView: View {
  @State var results = [Result]()
  
  var body: some View {
    List(results, id: \.trackId) { item in
      VStack(alignment: .leading) {
        Text(item.trackName)
          .font(.headline)
        
        Text(item.collectionName)
      }
    }
    .onAppear(perform: loadData)
  }
  
  func loadData() {
    /**
     There are four stages to complete during the asyncronous HTTP request to the Apple REST API.
     
     - The url must be constructed.
     - Then the url is wrapped in a URLRequest, which allows configuration of the URLRequest.
     - Create and start a networking task from the URL request.
     - Handle the response from the URLRequest.
     
     Create a url.
     guard statement used to protect the for the optional value.
     It could be an empty string. Eg: ""
     */
    guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&enity=song") else {
      print("Invalid URL")
      return
    }
    /**
     Create and initialize a URL request with the url.
     Cache policy, and timeout interval are additional unused arguments.
     */
    let request = URLRequest(url: url)
    /**
     Create and start a networking task from the URL request.
     The data, response, and error will be the arguments inside the completionHandler closure.

     Important: Without the trailing .resume() method, this URLSession will never start. (The app will just freeze.)
     */
    URLSession.shared.dataTask(with: request) { data, response, error in
      /**
       Handle the response in closure.
       The UI is always handled on the main thread (ie, the one is was created on).
       It's recommended that we make the call on a background thread.
       When the request is complete update the main thread, keeping the UI up to date.
       DispatchQueue will handle passing the completed request from the background to the main thread.
       */
      /**
       If the 'data' parameter from the completion Handler is true, the the request has been successful.
       Check for truth value the store the data as a variable.
       */
      if let data = data {
        if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
          /**
           If this part of the closure is reached, everything has been succesful and the response has been decoded.
           So the data in the decodedResponse.results is stored in self.results.
           The DispatchQueue method will handle the transferrance from background thread to main thread.
           */
          DispatchQueue.main.async {
            self.results = decodedResponse.results
          }
          /**
           Exit the cloure, all is complete.
           */
          return
        }
      }
      /**
       If this part of the closure has been reached there has been an error.
        Handle the case on unknown error with null coalecing.
       */
      print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }.resume()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
