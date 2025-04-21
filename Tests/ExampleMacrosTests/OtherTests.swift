import Foundation
import XCTest
@testable import ExampleMacros

final class ExampleTests: XCTestCase {
    func test_BookStore_WithStock_WhenBuyingLastBook_ShouldReceiveLatestRelease() throws {
        let oneDay: TimeInterval = 24 * 60 * 60
        
        let bookStore = BookStore(
            books: [
                Book(
                    title: "book 1",
                    releaseDate: .now.addingTimeInterval(-3 * oneDay)
                ),
                Book(
                    title: "book 2",
                    releaseDate: .now.addingTimeInterval(-oneDay)
                ),
                Book(
                    title: "book 3",
                    releaseDate: .now.addingTimeInterval(-2 * oneDay)
                )
            ]
        )
        
        XCTAssertEqual(bookStore.buyLastAvailableBook().title, "book 2")
    }
}

struct BookStore {
    let books: [Book]
    
    func buyLastAvailableBook() -> Book {
        books.sorted { $0.releaseDate > $1.releaseDate }
            .first!
    }
}

enum BookCategory {
    case thriller
    case fantasy
}

struct Chapter {
    let number: Int
}

struct Book {
    let title: String
    let subtitle: String?
    let author: String
    let releaseDate: Date
    let numberOfPages: Int
    let chapters: [Chapter]
    
    init(
        title: String,
        subtitle: String? = nil,
        author: String = "",
        releaseDate: Date,
        numberOfPages: Int = 0,
        chapters: [Chapter] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.author = author
        self.releaseDate = releaseDate
        self.numberOfPages = numberOfPages
        self.chapters = chapters
    }
}
