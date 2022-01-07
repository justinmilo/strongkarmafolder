//
//  File.swift
//  
//
//  Created by Justin Smith on 1/6/22.
//

import Foundation
import Models


public struct FileClient {
   public var load : () -> [Meditation]
   public var save : ([Meditation]) -> () = saveItems
}

extension FileClient {
    public static var live: Self {
        FileClient(load: _load, save: saveItems)
    }
}


func saveItems(item: Array<Meditation>) {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let data = try! encoder.encode(item)
  do {
    if let url = getDocumentsURL() {
      try data.write(to: url)
    }else {
      fatalError()
    }
  } catch {
    fatalError()
  }
  
}

func getDocumentsURL() -> URL?{
  do {
    let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
    let fileURL = documentDirectory.appendingPathComponent("Items.json")
    return fileURL
  }
  catch {
    return nil
  }
}


func _load() -> [Meditation] {
  let documentsResult = _loadFromDocuments()
  if case .success = documentsResult {
    print ("Document loadFromDocuments ")
    return try! documentsResult.get()
  }
 let bundleResult : [Meditation] = _extraLoad("meditationsData.json")()
  print ("Document loadFromBundle ")

   saveItems(item: bundleResult)
  return bundleResult
}

func _extraLoad<T: Decodable>(_ filename: String) -> () -> T {
  return {
    _loadFromBundle(filename)
  }
}


enum LoadError : Error {
  case noData
  case badData
  case noJson
  case badURL
  case badDocumentsURL
  case couldntWrite
}

func _loadFromDocuments() -> Result<[Meditation], LoadError>{
  
  guard let url = getDocumentsURL() else {
    print ("no persistenceURL ")

    return .failure( LoadError.badURL )
  }
  guard let data = try? Data(contentsOf: url) else {
    print (" LoadError.noData ")

    return .failure( LoadError.noData )
  }
  print(url)
  do {
    let decoder = JSONDecoder()
    let jsonData = try decoder.decode(Array<Meditation>.self, from: data)
    return .success(jsonData)
  } catch  {
    print (error)
    print (" LoadError.noJson ")

    return .failure(.noJson)
  }
}


func _loadFromBundle<T: Decodable>(_ filename: String, as type: T.Type = T.self) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

