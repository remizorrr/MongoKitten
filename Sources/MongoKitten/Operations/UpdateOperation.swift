import BSON
import Async

public struct Update: Command, Operation {
    public struct Single: Encodable {
        public var q: Query
        public var u: Document
        public var collation: Collation?
        public var upsert: Bool?
        public var multi: Bool?
        
        public init(matching query: Query, to document: Document) {
            self.q = query
            self.u = document
        }
        
        public func execute(on connection: DatabaseConnection, collection: Collection) throws -> Future<Reply.Update> {
            let updates = Update(self, in: collection)
            
            return try updates.execute(on: connection)
        }
    }
    
    var targetCollection: MongoCollection {
        return update
    }
    
    public let update: Collection
    public var updates: [Single]
    public var ordered: Bool?
    public var writeConcern: WriteConcern?
    public var bypassDocumentValidation: Bool?
    
    static var writing = true
    static var emitsCursor = false
    
    public init(matching query: Query, to document: Document, in collection: Collection) {
        self.init(
            Single(matching: query, to: document),
            in: collection
        )
    }
    
    public init(_ updates: Single..., in collection: Collection) {
        self.init(updates, in: collection)
    }
    
    public init<S: Sequence>(_ updates: S, in collection: Collection) where S.Element == Single {
        self.update = collection
        self.updates = Array(updates)
        
        self.writeConcern = collection.default.writeConcern
    }
    
    public func execute(on connection: DatabaseConnection) throws -> Future<Reply.Update> {
        return try connection.execute(self, expecting: Reply.Update.self) { reply, _ in
            guard reply.ok == 1 else {
                throw reply
            }
            
            return reply
        }
    }
}

extension Reply {
    public struct Update: Codable, Error {
        public var n: Int?
        public var ok: Int
        public var nModified: Int
        public var upserted: [Document]? // TODO: type-safe? We cannot (easily) decode the _id
        public var writeErrors: [Errors.Write]?
        public var writeConcernError: [Errors.WriteConcern]?
    }
}