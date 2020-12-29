extension ApiResponse {
    /**
     * Namespace of response models related to stock time series APIs.
     */
    public struct StockTimeSeries {
        /// Response model of `TIME_SERIES_INTRADAY` API.
        public struct STSIntraday: Decodable {
            var metadata: Metadata?
            var data: [String: MarketDataStandard]?

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: GenericCodingKeys.self)
                for key in container.allKeys {
                    if key.stringValue == "Meta Data" {
                        metadata = try container.decode(
                            Metadata.self, forKey: key
                        )

                        continue
                    }

                    data = try container.decode(
                        [String: MarketDataStandard].self, forKey: key
                    )
                }
            }

            public struct Metadata: Decodable {
                let information: String
                let symbol: String
                let lastRefresh: String
                let interval: String
                let outputSize: String
                let tz: String

                private enum CodingKeys: String, CodingKey {
                    case information = "1. Information"
                    case symbol = "2. Symbol"
                    case lastRefresh = "3. Last Refreshed"
                    case interval = "4. Interval"
                    case outputSize = "5. Output Size"
                    case tz = "6. Time Zone"
                }
            }
        }
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stockQuerySeries = try StockQuerySeries(json)

import Foundation

// MARK: - StockQuerySeries
public struct StockQuerySeries: Codable {
    public let bestMatches: [BestMatch]
}

// MARK: StockQuerySeries convenience initializers and mutators

extension StockQuerySeries {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(StockQuerySeries.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        bestMatches: [BestMatch]? = nil
    ) -> StockQuerySeries {
        return StockQuerySeries(
            bestMatches: bestMatches ?? self.bestMatches
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - BestMatch
public struct BestMatch: Codable, Hashable {
    public let the1Symbol, the2Name, the3Type, the4Region: String
    public let the5MarketOpen, the6MarketClose, the7Timezone, the8Currency: String
    public let the9MatchScore: String
    

    enum CodingKeys: String, CodingKey {
        case the1Symbol = "1. symbol"
        case the2Name = "2. name"
        case the3Type = "3. type"
        case the4Region = "4. region"
        case the5MarketOpen = "5. marketOpen"
        case the6MarketClose = "6. marketClose"
        case the7Timezone = "7. timezone"
        case the8Currency = "8. currency"
        case the9MatchScore = "9. matchScore"
    }
    
    
}

// MARK: BestMatch convenience initializers and mutators

extension BestMatch {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BestMatch.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        the1Symbol: String? = nil,
        the2Name: String? = nil,
        the3Type: String? = nil,
        the4Region: String? = nil,
        the5MarketOpen: String? = nil,
        the6MarketClose: String? = nil,
        the7Timezone: String? = nil,
        the8Currency: String? = nil,
        the9MatchScore: String? = nil
    ) -> BestMatch {
        return BestMatch(
            the1Symbol: the1Symbol ?? self.the1Symbol,
            the2Name: the2Name ?? self.the2Name,
            the3Type: the3Type ?? self.the3Type,
            the4Region: the4Region ?? self.the4Region,
            the5MarketOpen: the5MarketOpen ?? self.the5MarketOpen,
            the6MarketClose: the6MarketClose ?? self.the6MarketClose,
            the7Timezone: the7Timezone ?? self.the7Timezone,
            the8Currency: the8Currency ?? self.the8Currency,
            the9MatchScore: the9MatchScore ?? self.the9MatchScore
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
