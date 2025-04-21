import ExampleMacros
import Foundation

struct BookStore {
    let books: [Book]
}

@MockData
enum BookCategory {
    case thriller
    case fantasy
}

@MockData
struct Chapter {
    let number: Int
}

@MockData
struct Book {
    let title: String
    let subtitle: String?
    let author: String
    let releaseDate: Date
    let numberOfPages: Int
    let chapters: [Chapter]
}
