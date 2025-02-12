import SwiftLintCore

struct ImplicitReturnConfiguration: SeverityBasedRuleConfiguration, Equatable {
    typealias Parent = ImplicitReturnRule

    enum ReturnKind: String, CaseIterable, AcceptableByConfigurationElement, Comparable {
        case closure
        case function
        case getter
        case `subscript`
        case initializer

        func asOption() -> OptionType { .symbol(rawValue) }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    static let defaultIncludedKinds = Set(ReturnKind.allCases)

    @ConfigurationElement(key: "severity")
    private(set) var severityConfiguration = SeverityConfiguration<Parent>(.warning)
    @ConfigurationElement(key: "included")
    private(set) var includedKinds = Self.defaultIncludedKinds

    init(includedKinds: Set<ReturnKind> = Self.defaultIncludedKinds) {
        self.includedKinds = includedKinds
    }

    mutating func apply(configuration: Any) throws {
        guard let configuration = configuration as? [String: Any] else {
            throw Issue.unknownConfiguration(ruleID: Parent.identifier)
        }

        if let includedKinds = configuration[$includedKinds] as? [String] {
            self.includedKinds = try Set(includedKinds.map {
                guard let kind = ReturnKind(rawValue: $0) else {
                    throw Issue.unknownConfiguration(ruleID: Parent.identifier)
                }

                return kind
            })
        }

        if let severityString = configuration[$severityConfiguration] as? String {
            try severityConfiguration.apply(configuration: severityString)
        }
    }

    func isKindIncluded(_ kind: ReturnKind) -> Bool {
        return self.includedKinds.contains(kind)
    }
}
