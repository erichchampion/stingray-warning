import Foundation

/// Manages UserDefaults operations asynchronously to avoid blocking the main thread
class UserDefaultsManager {
    
    // MARK: - Synchronous Operations (for critical data)
    
    static func set<T>(_ value: T?, forKey key: String) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    static func get<T>(forKey key: String, defaultValue: T) -> T {
        return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    
    static func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
        return UserDefaults.standard.object(forKey: key) as? Bool ?? defaultValue
    }
    
    static func getString(forKey key: String, defaultValue: String = "") -> String {
        return UserDefaults.standard.string(forKey: key) ?? defaultValue
    }
    
    static func getData(forKey key: String) -> Data? {
        return UserDefaults.standard.data(forKey: key)
    }
    
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Asynchronous Operations (for non-critical data)
    
    static func setAsync<T>(_ value: T, forKey key: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            UserDefaults.standard.set(value, forKey: key)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    static func getAsync<T>(forKey key: String, defaultValue: T, completion: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let value = UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            DispatchQueue.main.async {
                completion(value)
            }
        }
    }
    
    static func removeAsync(forKey key: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            UserDefaults.standard.removeObject(forKey: key)
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    // MARK: - Codable Support
    
    static func setCodable<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        set(data, forKey: key)
    }
    
    static func getCodable<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = getData(forKey: key) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    static func setCodableAsync<T: Codable>(_ object: T, forKey key: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        DispatchQueue.global(qos: .utility).async {
            do {
                let data = try JSONEncoder().encode(object)
                set(data, forKey: key)
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    static func getCodableAsync<T: Codable>(_ type: T.Type, forKey key: String, completion: @escaping (Result<T?, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            do {
                guard let data = getData(forKey: key) else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                    return
                }
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Convenience Methods for App-Specific Keys
    
    static func setMonitoringEnabled(_ enabled: Bool) {
        set(enabled, forKey: AppConstants.UserDefaultsKeys.monitoringEnabled)
    }
    
    static func getMonitoringEnabled() -> Bool {
        return getBool(forKey: AppConstants.UserDefaultsKeys.monitoringEnabled)
    }
    
    static func setNotificationEnabled(_ enabled: Bool) {
        set(enabled, forKey: AppConstants.UserDefaultsKeys.notificationEnabled)
    }
    
    static func getNotificationEnabled() -> Bool {
        return getBool(forKey: AppConstants.UserDefaultsKeys.notificationEnabled, defaultValue: true)
    }
    
    static func setBackgroundMonitoringEnabled(_ enabled: Bool) {
        set(enabled, forKey: AppConstants.UserDefaultsKeys.backgroundMonitoringEnabled)
    }
    
    static func getBackgroundMonitoringEnabled() -> Bool {
        return getBool(forKey: AppConstants.UserDefaultsKeys.backgroundMonitoringEnabled, defaultValue: true)
    }
}
