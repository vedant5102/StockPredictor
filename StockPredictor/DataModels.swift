//
//  DataModels.swift
//  StockPredictor
//
//  Created by vedant katre on 11/09/25.
//

import Foundation

// --- Data Models for Decoding API Response ---

// This struct matches the overall structure of the JSON from Alpha Vantage.
struct AlphaVantageResponse: Codable {
    let timeSeriesDaily: [String: StockDataPoint]?
    let note: String? // This is the added line to fix the error.

    enum CodingKeys: String, CodingKey {
        case timeSeriesDaily = "Time Series (Daily)"
        case note = "Note"
    }
}

// This struct holds the daily stock data (close price, volume).
struct StockDataPoint: Codable {
    let close: String
    let volume: String

    enum CodingKeys: String, CodingKey {
        case close = "4. close"
        case volume = "5. volume"
    }
}

// --- Data Model for Use Within the App ---

// This is the clean data structure we use throughout the app's views and logic.
struct HistoricalDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let close: Double
    let volume: Int
}


// A simple DateFormatter to convert strings like "2023-09-11" into Date objects.
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

