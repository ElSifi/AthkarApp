//
//  AthkarLoader.swift
//  DailyAthkar
//
//  JSON loading service
//

import Foundation

enum AthkarLoader {
    static func loadSections() -> [AthkarSection] {
        guard let url = Bundle.main.url(forResource: "db", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let sections = try? JSONDecoder().decode([AthkarSection].self, from: data)
        else { return [] }
        return sections
    }
}
