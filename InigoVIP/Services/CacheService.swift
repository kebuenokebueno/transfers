//
//  CacheService.swift
//  InigoVIP
//
//  Created by Inigo on 28/1/26.
//

actor CacheService {
    private var cache: [String: Any] = [:]
    
    func get<T>(key: String) async -> T? {
        return cache[key] as? T
    }
    
    func set<T>(key: String, value: T) async {
        cache[key] = value
    }
    
    func clear() async {
        cache.removeAll()
    }
}
