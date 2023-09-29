import Foundation
import SwiftSyntax
import SourceKittenFramework

struct ViewControllerProtocolNameRequirementRule: ConfigurationProviderRule, SwiftSyntaxRule {
    var configuration = SeverityConfiguration<Self>(.error)

    static let description = RuleDescription(
        identifier: "vc_protocol_name_rule",
        name: "ViewController protocol name requirement rule",
        description: "Protocols inherited from UIViewController should have Input suffix",
        kind: .style,
        nonTriggeringExamples: [Example("protocol GmojiOwnGiftsTabsControllerInput: UIViewController {}")],
        triggeringExamples: [Example("protocol GmojiOwnGiftsTabsController↓: UIViewController {}")]
    )

   
    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        ViewControllerProtocolNameRequirementRuleVisitor(viewMode: .sourceAccurate)
    }
}

private final class ViewControllerProtocolNameRequirementRuleVisitor: ViolationsSyntaxVisitor {
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.inheritanceClause.containsInheritedType(inheritedTypes: ["UIViewController"]) && !node.name.text.hasSuffix("Input") {
            violations.append(node.name.endPosition)
            
            return .skipChildren
        }
        
        return .visitChildren
        
    }
}

