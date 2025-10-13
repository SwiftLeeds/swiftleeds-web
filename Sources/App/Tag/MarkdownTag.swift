@preconcurrency import LeafKit
import SwiftMarkdown

struct MarkdownTag: UnsafeUnescapedLeafTag {
    enum Error: Swift.Error {
        case invalidArgument(LeafData?)
    }
    
    private let options: MarkdownOptions?
    
    init(options: MarkdownOptions? = nil) {
        self.options = options
    }
    
    func render(_ ctx: LeafContext) throws -> LeafData {
        var markdown = ""
        
        if let markdownArgument = ctx.parameters.first, !markdownArgument.isNil {
            guard let markdownArgumentValue = markdownArgument.string else {
                throw Error.invalidArgument(ctx.parameters.first)
            }
            markdown = markdownArgumentValue
        }

        let markdownHTML: String = if let options {
            try markdownToHTML(markdown, options: options)
        } else {
            try markdownToHTML(markdown)
        }

        return .string(markdownHTML)
    }
}
