//
//  Player.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID = UUID()
    var name: String = ""
    var genderRaw: String = Gender.male.rawValue
    var skillLevelRaw: Int = SkillLevel.beginner.rawValue
    var isSelected: Bool = true
    var avatarIndex: Int = 0

    var group: GroupGame?

    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .male }
        set { genderRaw = newValue.rawValue }
    }

    var skillLevel: SkillLevel {
        get { SkillLevel(rawValue: skillLevelRaw) ?? .beginner }
        set { skillLevelRaw = newValue.rawValue }
    }

    init(name: String, gender: Gender, skillLevel: SkillLevel, isSelected: Bool = true) {
        self.id = UUID()
        self.name = name
        self.genderRaw = gender.rawValue
        self.skillLevelRaw = skillLevel.rawValue
        self.isSelected = isSelected
        self.avatarIndex = Int.random(in: 0..<4)
    }
}
