//
//  PlayerSupportTypes.swift
//  teamgenerator
//
//  Created by Paulo Roberto C. on 14/08/26.
//

import SwiftUI

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum SkillLevel: Int, Codable, CaseIterable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
    case expert = 4
    case pro = 5

    var label: String {
        switch self {
        case .beginner: return "Iniciante"
        case .intermediate: return "Intermediário"
        case .advanced: return "Avançado"
        case .expert: return "Especialista"
        case .pro: return "Profissional"
        }
    }
}

enum PlayerPosition: String, Codable, CaseIterable {
    case setter = "Setter"
    case libero = "Libero"
    case spiker = "Spiker"
    case blocker = "Blocker"
    case server = "Server"
    case utility = "Utility"

    var label: String {
        switch self {
        case .setter:  return "Levantador"
        case .libero:  return "Líbero"
        case .spiker:  return "Ponteiro"
        case .blocker: return "Bloqueador"
        case .server:  return "Sacador"
        case .utility: return "Universal"
        }
    }
}

enum MatchRotationRule: String, Codable, CaseIterable {
    case sequential = "Sequential"
    case winStreakExit = "WinStreakExit"

    var label: String {
        switch self {
        case .sequential:   return "Sequenciada"
        case .winStreakExit: return "2 vitórias e sai"
        }
    }

    var explanation: String {
        switch self {
        case .sequential:
            return "Quem vence fica na quadra; só o desafiante da fila entra."
        case .winStreakExit:
            return "Vencer 2x seguidas tira o time da quadra — ele volta com prioridade na fila, na frente de quem já espera. Só entra em ação em sessões com mais de 3 times; com 3 ou menos, funciona como a sequenciada."
        }
    }
}

enum SessionStatus: String, Codable, CaseIterable {
    case completed = "Completed"
    case cancelled = "Cancelled"

    var label: String {
        switch self {
        case .completed: return "Concluída"
        case .cancelled:  return "Cancelada"
        }
    }
}

enum SportType: String, Codable, CaseIterable {
    case volleyball = "Volleyball"
    case futsal     = "Futsal"
    case basketball = "Basketball"
    case custom     = "Custom"

    var icon: String {
        switch self {
        case .volleyball:  return "volleyball"
        case .futsal:      return "soccerball"
        case .basketball:  return "basketball"
        case .custom:      return "sportscourt"
        }
    }

    var label: String {
        switch self {
        case .volleyball:  return "Vôlei"
        case .futsal:      return "Futsal"
        case .basketball:  return "Basquete"
        case .custom:      return "Personalizado"
        }
    }

    var color: Color {
        switch self {
        case .volleyball:  return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .futsal:      return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .basketball:  return Color(red: 1.0, green: 0.3, blue: 0.5)
        case .custom:      return Color(red: 0.5, green: 0.5, blue: 0.8)
        }
    }
}
