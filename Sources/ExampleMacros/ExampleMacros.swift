// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension, names: arbitrary)
public macro MockData() = #externalMacro(module: "ExampleMacrosMacros", type: "MockDataMacro")
