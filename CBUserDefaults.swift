//
//  CBUserDefaults.swift
//  CB
//
//  Created by Umair on 23/10/2019.
//  Copyright © 2019 citrusbits. All rights reserved.
//

import Foundation

// MARK: - Main Struct

struct UserDefaultObject<Value> {
    
    var key: String
    private var value: Value?
    
    init(key k: String) {
        key = k
    }
    
    mutating func clear() {
        value = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Codable extension

extension UserDefaultObject where Value: Codable {
    
    mutating func get() -> Value? {
        
        if value == nil {
            let decoder = JSONDecoder()
            
            if let data = UserDefaults.standard.data(forKey: key),
                let val = try? decoder.decode(Value.self, from: data) {
                value = val
            }
        }
        
        return value
    }
    
    mutating func set(value val: Value) {
        value = val
        let encoder = JSONEncoder()
        
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// MARK: - String extension

extension UserDefaultObject where Value == String {
    
    mutating func get() -> Value? {
        
        if value == nil {
            value =  UserDefaults.standard.string(forKey: key)
        }
        
        return value
    }
    
    mutating func set(value val: Value) {
        value = val
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - Int extension

extension UserDefaultObject where Value == Int {
    
    mutating func get() -> Value? {
        
        if value == nil {
            value =  UserDefaults.standard.integer(forKey: key)
        }
        
        return value
    }
    
    mutating func set(value val: Value) {
        value = val
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - Double extension

extension UserDefaultObject where Value == Double {
    
    mutating func get() -> Value? {
        
        if value == nil {
            value =  UserDefaults.standard.double(forKey: key)
        }
        
        return value
    }
    
    mutating func set(value val: Value) {
        value = val
        UserDefaults.standard.set(value, forKey: key)
    }
}

// MARK: - Bool extension

extension UserDefaultObject where Value == Bool {
    
    mutating func set(value val: Value) {
        value = val
        UserDefaults.standard.set(value, forKey: key)
    }
    
    mutating func get() -> Value {
        
        if value == nil {
            value =  UserDefaults.standard.bool(forKey: key)
        }
        
        return value ?? false
    }
}

// MARK: - Date extension

extension UserDefaultObject where Value == Date {
   
    mutating func get() -> Value? {
        
        if value == nil {
            var doubleValue = UserDefaultObject<Double>(key: key)
            
            if let timeInterval = doubleValue.get() {
                
                if timeInterval != 0 {
                    value = Date(timeIntervalSince1970: timeInterval)
                }
            }
        }
        return value
    }
    
    mutating func set(value val: Value) {
        value = val
        UserDefaults.standard.set(value!.timeIntervalSince1970, forKey: key)
    }
}

// MARK: - String Array extension

extension UserDefaultObject where Value == [String] {
    
    mutating func get() -> Value? {
        
        if value == nil {
            
            if let array = UserDefaults.standard.array(forKey: key) as? [String] {
                debugPrint("Array: \(array)")
                value = array
            }
        }
        
        return value
    }
    
    mutating func append(value: String) {
        var array: [String] = []
        
        if let tempArray = get() {
            array.append(contentsOf: tempArray)
        }
        
        array.append(value)
        UserDefaults.standard.set(array, forKey: key)
    }
}

// MARK: - How to use
// Create a struct and initialze with key for the object type to be used
//struct CBUserDefaults {
//    static var aString = UserDefaultObject<String>(key: "aString")
//}

// Just call the following to get and save
//CBUserDefaults.aString.set(value: "Hello")
//let savedString = CBUserDefaults.aString.get()
