// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let stockAPI = try StockAPI(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.stockAPITask(with: url) { stockAPI, response, error in
//     if let stockAPI = stockAPI {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - StockAPI
struct StockAPI: Codable {
    let c, h, l, o: Double
    let pc: Double
    let t: Int
}

// MARK: StockAPI convenience initializers and mutators

extension StockAPI {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(StockAPI.self, from: data)
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
        c: Double? = nil,
        h: Double? = nil,
        l: Double? = nil,
        o: Double? = nil,
        pc: Double? = nil,
        t: Int? = nil
    ) -> StockAPI {
        return StockAPI(
            c: c ?? self.c,
            h: h ?? self.h,
            l: l ?? self.l,
            o: o ?? self.o,
            pc: pc ?? self.pc,
            t: t ?? self.t
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

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func stockAPITask(with url: URL, completionHandler: @escaping (StockAPI?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
