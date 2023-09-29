import Foundation
import SwiftSyntax
import SourceKittenFramework

struct PresenterNameRule: ConfigurationProviderRule, SwiftSyntaxRule {
    var configuration = SeverityConfiguration<Self>(.error)

    static let description = RuleDescription(
        identifier: "presenter_impl_name_rule",
        name: "Presenter name rule",
        description: "Presenters implementing protocols should be named as [PresenterProtocol]Impl",
        kind: .style,
        nonTriggeringExamples: [
            Example("""
                protocol AllProductsPresenter {

                }

                final class AllProductsPresenterImpl: AllProductsPresenter {
                    
                    weak var view: AllProductsView?
                }

                extension AllProductsPresenterImpl: OtherProtocol {
                  
                }
            """),
            Example("""
                protocol AllProductsPresenter {

                }

                final class AllProductsPresenterImpl  {
                    
                    weak var view: AllProductsView?
                }

                extension AllProductsPresenterImpl: AllProductsPresenter {
                  
                }
            """)
        ],
        triggeringExamples: [
            Example("""
                protocol AllProductsPresenter {

                }

                final class AllProductsViewModel↓: AllProductsPresenter {
                    
                    weak var view: AllProductsView?
                }
            """),
            Example("""
                protocol AllProductsPresenter {

                }

                final class AllProductsViewModel {
                    
                    weak var view: AllProductsView?
                }
            
                extension AllProductsViewModel↓: AllProductsPresenter {
                  
                }
            """)
        ]
    )

   
    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        PresenterNameRuleRuleVisitor(viewMode: .sourceAccurate)
    }
}

private final class PresenterNameRuleRuleVisitor: ViolationsSyntaxVisitor {
    
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let extendedType = node.extendedType.as(IdentifierTypeSyntax.self) else {
            return .visitChildren
        }
        
//        print(extendedType.name.text)
        
        let derivedPresenter = node
            .inheritanceClause?
            .inheritedTypes
            .compactMap { $0.type.as(IdentifierTypeSyntax.self) }
            .first { $0.name.text.hasSuffix("Presenter") }

        guard let derivedPresenter else { return .visitChildren }
        
        if !extendedType.name.text.hasSuffix("\(derivedPresenter.name.text)Impl") {
            violations.append(node.extendedType.endPosition)
            
            return .skipChildren
        }
        
        return .visitChildren
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        
        let derivedPresenter = node
            .inheritanceClause?
            .inheritedTypes
            .compactMap { $0.type.as(IdentifierTypeSyntax.self) }
            .first { $0.name.text.hasSuffix("Presenter") }
            
        guard let derivedPresenter else { return .visitChildren }
        
        
        
        if !node.name.text.hasSuffix("\(derivedPresenter.name.text)Impl") {
            violations.append(node.name.endPosition)
            
            return .skipChildren
        }
        
        return .visitChildren
    }
 
}

