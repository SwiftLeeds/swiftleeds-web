import Vapor

struct SlackMessage: Content {
    let channel: String
    let icon_emoji: String
    let username: String
    let blocks: [SlackBlock]
    
    struct SlackBlock: Content {
        let type: BlockType
        let text: SlackText?
        
        init(type: BlockType, text: SlackText? = nil) {
            self.type = type
            self.text = text
        }
        
        enum BlockType: String, Content {
            case divider
            case section
        }
        
        struct SlackText: Content {
            let type: TextType
            let text: String
            
            enum TextType: String, Content {
                case markdown = "mrkdwn"
            }
        }
    }
}

// MARK: - Send message

extension SlackMessage {
    func send(req: Request) async throws {
        guard let slackWebhook = Environment.get("SLACK_WEBHOOK") else {
            throw Abort(.notFound)
        }
        
        _ = try await req.client.post(URI(string: slackWebhook), content: self)
    }
}
