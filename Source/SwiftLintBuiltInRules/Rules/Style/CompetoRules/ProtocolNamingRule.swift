import Foundation
import SwiftSyntax
import SourceKittenFramework

struct ProtocolNamingRule: ConfigurationProviderRule, SwiftSyntaxRule {
    var configuration = SeverityConfiguration<Self>(.error)
    
    static let description = RuleDescription(
        identifier: "protocol_name_rule",
        name: "Protocol name rule",
        description: "Regular protocols should have Protocol suffix",
        kind: .style,
        nonTriggeringExamples: [
            Example("""
                protocol AllProductsPresenter {
            
                }
            """),
            Example("""
                protocol SomeService {
            
                }
            """),
            Example("""
                protocol SomeInput {
            
                }
            """),
            Example("""
                protocol SomeOutput {
            
                }
            """),
            Example("""
                protocol NewsDetailsView: UIViewController {
            
                }
            """)
        ],
        triggeringExamples: [
            Example("""
                protocol AllProducts↓{
            
                }
            """),
            Example("""
                protocol SomeCodable↓: Codable {
            
                }
            """),
            Example("""
                protocol OtherProto ↓{
            
                }
            """)
        ]
    )
    
    
    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        ProtocolNamingRuleVisitor(viewMode: .sourceAccurate)
    }
}

private final class ProtocolNamingRuleVisitor: ViolationsSyntaxVisitor {
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        
        print(node.name.text)
        
        if (
            !node.inheritanceClause.containsInheritedType(inheritedTypes: ["UIViewController"]) &&
            !node.name.text.hasSuffix("Presenter") &&
            !node.name.text.hasSuffix("Service") &&
            !node.name.text.hasSuffix("Input") &&
            !node.name.text.hasSuffix("Output") &&
            !node.name.text.hasSuffix("Delegate") &&
            !node.name.text.hasSuffix("ViewModel")
        ) &&
            !node.name.text.hasSuffix("Protocol") {
            violations.append(node.name.endPosition)
            
            print("Violation: \(node.name.text)")
            
            return .skipChildren
        }
        
        return .visitChildren
    }
    
}

