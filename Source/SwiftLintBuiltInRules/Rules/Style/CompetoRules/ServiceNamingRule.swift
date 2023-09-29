import Foundation
import SwiftSyntax
import SourceKittenFramework

struct ServiceNamingRule: ConfigurationProviderRule, SwiftSyntaxRule {
    var configuration = SeverityConfiguration<Self>(.error)

    static let description = RuleDescription(
        identifier: "service_name_rule",
        name: "Service name rule",
        description: "Service classes should have Impl suffix",
        kind: .style,
        nonTriggeringExamples: [
            Example("""
                protocol SomeService {

                }

                final class SomeServiceImpl: SomeService {
            
                }

                extension SomeServiceImpl: OtherProtocol {
                  
                }
            """),
            Example("""
                protocol SomeService {

                }

                final class SomeServiceImpl  {
                    
                }

                extension SomeServiceImpl: SomeService {
                  
                }
            """)
        ],
        triggeringExamples: [
            Example("""
                protocol SomeService {

                }

                final class SomeServiceImplementation↓: SomeService {
                    
                }
            """),
            Example("""
                protocol SomeService {

                }

                final class SomeServiceClass {
                    
                }
            
                extension SomeServiceClass↓: SomeService {
                  
                }
            """)
        ]
    )

   
    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        ServiceNamingRuleVisitor(viewMode: .sourceAccurate)
    }
}

private final class ServiceNamingRuleVisitor: ViolationsSyntaxVisitor {
    
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let extendedType = node.extendedType.as(IdentifierTypeSyntax.self) else {
            return .visitChildren
        }
        
//        print(extendedType.name.text)
        
        let derivedService = node
            .inheritanceClause?
            .inheritedTypes
            .compactMap { $0.type.as(IdentifierTypeSyntax.self) }
            .first { $0.name.text.hasSuffix("Service") }

        guard let derivedService else { return .visitChildren }
        
        if !extendedType.name.text.hasSuffix("\(derivedService.name.text)Impl") {
            violations.append(node.extendedType.endPosition)
            
            return .skipChildren
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        
        let derivedService = node
            .inheritanceClause?
            .inheritedTypes
            .compactMap { $0.type.as(IdentifierTypeSyntax.self) }
            .first { $0.name.text.hasSuffix("Service") }
            
        guard let derivedService else { return .visitChildren }
        
        
        
        if !node.name.text.hasSuffix("\(derivedService.name.text)Impl") {
            violations.append(node.name.endPosition)
            
            return .skipChildren
        }
        
        return .visitChildren
    }
 
}

