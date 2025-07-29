import Foundation

protocol JSONCodable: Codable {}

struct Request<T: JSONCodable>: Codable {
    let data: T
}

enum FileStorageError: Error {
    case fileError(Error)
    case decodingError(Error)
    case encodingError(Error)
}

protocol RequestStorable {
    associatedtype RequestType: JSONCodable
    func saveRequest(key: String, request: Request<RequestType>, baseURL: URL) async throws
    func loadRequest(key: String, baseURL: URL) async throws -> Request<RequestType>?
}

class MyFileRequestStorage<T: JSONCodable>: RequestStorable {
    typealias RequestType = T

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private func getFileURL(forKey key: String, baseURL: URL) -> URL {
        return baseURL.appendingPathComponent("\(key).json")
    }

    func saveRequest(key: String, request: Request<RequestType>, baseURL: URL) async throws {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(request)
        let fileURL = getFileURL(forKey: key, baseURL: baseURL)

        do {
            try encodedData.write(to: fileURL, options: .atomic)
            print("Request saved successfully to file: \(fileURL)")
        } catch {
            print("Failed to save request to \(fileURL): \(error)")
            throw FileStorageError.fileError(error)
        }
    }

    func loadRequest(key: String, baseURL: URL) async throws -> Request<RequestType>? {
    let fileURL = getFileURL(forKey: key, baseURL: baseURL)

    guard fileManager.fileExists(atPath: fileURL.path) else {
        print("No request found at file: \(fileURL)")
        return nil
    }
    
    do {
        return try await Task { 
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let decodedRequest = try decoder.decode(Request<RequestType>.self, from: data)
                print("Request loaded successfully from file: \(fileURL)")
                return decodedRequest
            } catch {
                print("Failed to load or decode request from \(fileURL): \(error)")

                if error is DecodingError {
                    throw FileStorageError.decodingError(error)
                } else {
                    throw FileStorageError.fileError(error)
                }
            }
        }.value 
    } catch {
        print("Ошибка при выполнении Task: \(error)")
        return nil
    }
}
}
