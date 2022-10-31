//
//  ContentView.swift
//  api_test
//
//  Created by Mattias Spångberg on 2022-10-31.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var tvShows: [String] = []
    //let randomInt = Int.random(in: 1..<5)
    var body: some View {
        List{
            ForEach(Array(zip(tvShows.indices, tvShows)), id: \.0) { index, show in
              Text(show)
            }
        }
        Button {
            Task {
                do{
                    try await tvShows = getDisneyCharacter(charId: Int.random(in: 5..<25))
                }catch{
                    tvShows = ["There is not data to show"]
                }
            }
        } label: {
            Text("Fetch tv series")
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct DsCharacter: Codable {
    let tvShows: [String]
}

enum Errors: Error {
    case noDsChar
}

func getDisneyCharacter(charId: Int) async throws -> [String]{
    // Code uses URLSession which can create tasks that downloads data. the shared keyword is a task that is a singleton, in other words it is a task that you can reach if you only need one object. You should create your own task if you can.
    let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api.disneyapi.dev/characters/\(charId)")!)
    // JSONDecoder can decode json objects. It first takes an object that has member variables that match the json objects keys. Second it takes an object that has the json data. 
    let decodedResponse = try? JSONDecoder().decode(DsCharacter.self, from: data)
    
    print("the URL used was: " + "https://api.disneyapi.dev/characters/\(charId)")
    print(decodedResponse?.tvShows ?? "Api response was nil")
    
    if decodedResponse?.tvShows == nil{
        throw Errors.noDsChar
        
    }else if decodedResponse?.tvShows == []{
        return ["No shows"]
    }else {
        return decodedResponse?.tvShows ?? ["No value"]
    }
}
