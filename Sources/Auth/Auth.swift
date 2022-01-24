public struct Auth {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func show() {
        print("show me \(text)")
    }
}
