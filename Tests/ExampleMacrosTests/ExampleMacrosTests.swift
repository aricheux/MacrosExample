import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import ExampleMacrosMacros

let testMacros: [String: Macro.Type] = [
    "MockData": MockDataMacro.self,
]

final class ExampleMacrosTests: XCTestCase {
    func testEnumMacro() throws {
        assertMacroExpansion(
            """
            @MockData
            enum BookCategory {
                case thriller
                case fantasy
            }
            """,
            expandedSource: """
            enum BookCategory {
                case thriller
                case fantasy
            }
            
            extension BookCategory {
                static func mockData() -> BookCategory {
                    .thriller
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testStructMacro() throws {
        assertMacroExpansion(
            """
            @MockData
            struct Book {
                let title: String
                let subtitle: String?
                let author: String
                let releaseDate: Date
                let numberOfPages: Int
            }
            """,
            expandedSource: """
            struct Book {
                let title: String
                let subtitle: String?
                let author: String
                let releaseDate: Date
                let numberOfPages: Int
            }
            
            extension Book {
                static func mockData(
                    title: String = "",
                    subtitle: String? = nil,
                    author: String = "",
                    releaseDate: Date = Date(),
                    numberOfPages: Int = 0
                ) -> Book {
                    Book(
                        title: title,
                        subtitle: subtitle,
                        author: author,
                        releaseDate: releaseDate,
                        numberOfPages: numberOfPages
                    )
                }
            }
            """,
            macros: testMacros
        )
    }
}
