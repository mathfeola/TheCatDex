//
//  EnvironmentUtils.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import Foundation

public struct EnvironmentUtil {
    
    private var environment: [String: Any]? {
        get {
            Bundle.main.infoDictionary?["EnvironmentSetting"] as? [String: Any]
        }
    }
    
    public var catApiBaseUrl: String? {
        get {
            return environment?["THE_CAT_API_BASE_URL"] as? String
        }
    }
    
    public var catApiBaseUrlVersion: String? {
        get {
            return environment?["THE_CAT_API_VERSION"] as? String
        }
    }
    
    public var catApiKey: String? {
        get {
            return environment?["THE_CAT_API_KEY"] as? String
        }
    }
}

