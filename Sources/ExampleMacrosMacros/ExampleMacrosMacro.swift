import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MockDataMacro: ExtensionMacro {
    enum MockDataError: Error {
        case notAvailableForThisType
        case enumerationEmpty
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let members = attachedTo.memberBlock.members
        
        let staticFunction: FunctionDeclSyntax =
        switch attachedTo {
        case is StructDeclSyntax, is ClassDeclSyntax:
            try mockDataVariableSyntax(members: members, type: type)
        case is EnumDeclSyntax:
            try mockDataEnumerationSyntax(members: members, type: type)
        default:
            throw MockDataError.notAvailableForThisType
        }
        
        let extensionDecl = ExtensionDeclSyntax(extendedType: type) {
            MemberBlockItemSyntax(decl: staticFunction)
        }
        
        return [extensionDecl]
    }
}

private extension MockDataMacro {
    static func mockDataEnumerationSyntax(members: MemberBlockItemListSyntax, type: some TypeSyntaxProtocol) throws -> FunctionDeclSyntax {
        let enumCaseDecl = members.first?.decl.as(EnumCaseDeclSyntax.self)

        guard let enumCaseDecl, case .identifier(let id) = enumCaseDecl.elements.firstToken(viewMode: .sourceAccurate)?.tokenKind else {
            throw MockDataError.enumerationEmpty
        }

        var initialCode: String = "static func mockData() -> \(type.trimmed) {"
        initialCode += ".\(id)"
        initialCode += "}"

        return try FunctionDeclSyntax(SyntaxNodeString(stringLiteral: initialCode))
    }

    static func mockDataVariableSyntax(members: MemberBlockItemListSyntax, type: some TypeSyntaxProtocol) throws -> FunctionDeclSyntax {
        let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
        let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }

        return try FunctionDeclSyntax(
            generateVariableExtensionCode(
                extensionOf: type,
                variablesName: variablesName,
                variablesType: variablesType
            )
        )
    }
    
    static func generateVariableExtensionCode(
        extensionOf type: some TypeSyntaxProtocol,
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) -> SyntaxNodeString {
        let newLine: String = "\n"

        let trimmedType = type.trimmed
        var initialCode: String = "static func mockData("

        /// Parameters (name: String = "", ...)
        for (name, type) in zip(variablesName, variablesType) {
            initialCode += newLine
            initialCode += "\(name): \(type) = \(defaultValue(forType: type)), "
        }
        initialCode = String(initialCode.dropLast(2))
        initialCode += newLine

        initialCode += ") -> \(trimmedType) {"

        /// Initialize code -> Object(name: name, ..)
        initialCode += "\(trimmedType)("
        variablesName.forEach { name in
            initialCode += newLine
            initialCode += "\(name): \(name), "
        }
        initialCode = String(initialCode.dropLast(2))
        initialCode += newLine
        initialCode += ")"
        initialCode += "}"
        
        return SyntaxNodeString(stringLiteral: initialCode)
    }

    static func defaultValue(forType type: TypeSyntax) -> String {
    let typeSyntax = type.as(TypeSyntaxEnum.self)
    switch typeSyntax {
    case .arrayType:
        return "[]"
    case .identifierType(let identifierTypeSyntax):
        switch identifierTypeSyntax.name.tokenKind {
        case .identifier("URL"):
            return "URL(string: \"https://www.google.com\")!"
        case .identifier("Bool"):
            return "false"
        case .identifier("Int"), .identifier("Float"), .identifier("TimeInterval"), .identifier("Double"):
            return "0"
        case .identifier("String"):
            return "\"\""
        case .identifier("Date"):
            return "Date()"
        case .identifier("UUID"):
            return "UUID().uuidString"
        default:
            return ".mockData()"
        }
    case .optionalType:
        return "nil"
    default:
        return ".testData()"
    }
}
}

@main
struct generate_test_data_macroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockDataMacro.self,
    ]
}

