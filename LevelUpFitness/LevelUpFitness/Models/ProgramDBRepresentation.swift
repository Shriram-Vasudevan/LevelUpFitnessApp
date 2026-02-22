//
//  ProgramDBRepresentation.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/9/24.
//

import Foundation

struct UserProgramDBRepresentation: Codable {
    var userID: String
    var program: String
    var startDate: String
    var programID: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case program = "Program"
        case startDate = "StartDate"
        case programID = "ProgramID"
    }
}


struct StandardProgramDBRepresentation: Codable {
    var id: String
    var name: String
    var environment: String
    var image: String
    var description: String
    var isPremium: Bool
    var requiredSubscriptionProductIDs: [String]
    var requiredSubscriptionGroupID: String?

    var requiresSubscription: Bool {
        isPremium || !requiredSubscriptionProductIDs.isEmpty || requiredSubscriptionGroupID != nil
    }

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case environment = "Environment"
        case image = "Image"
        case description = "Description"
        case isPremium = "IsPremium"
        case requiredSubscriptionProductIDs = "RequiredSubscriptionProductIDs"
        case requiredSubscriptionGroupID = "RequiredSubscriptionGroupID"
    }

    init(
        id: String,
        name: String,
        environment: String,
        image: String,
        description: String,
        isPremium: Bool = false,
        requiredSubscriptionProductIDs: [String] = [],
        requiredSubscriptionGroupID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.environment = environment
        self.image = image
        self.description = description
        self.isPremium = isPremium
        self.requiredSubscriptionProductIDs = requiredSubscriptionProductIDs
        self.requiredSubscriptionGroupID = requiredSubscriptionGroupID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        environment = try container.decode(String.self, forKey: .environment)
        image = try container.decode(String.self, forKey: .image)
        description = try container.decode(String.self, forKey: .description)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        requiredSubscriptionProductIDs = try container.decodeIfPresent([String].self, forKey: .requiredSubscriptionProductIDs) ?? []
        requiredSubscriptionGroupID = try container.decodeIfPresent(String.self, forKey: .requiredSubscriptionGroupID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(environment, forKey: .environment)
        try container.encode(image, forKey: .image)
        try container.encode(description, forKey: .description)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(requiredSubscriptionProductIDs, forKey: .requiredSubscriptionProductIDs)
        try container.encodeIfPresent(requiredSubscriptionGroupID, forKey: .requiredSubscriptionGroupID)
    }
}
