import Schrodinger

extension Collection {
    public func findOneAsync(_ query: Query? = nil, sortedBy sort: Sort? = nil, projecting projection: Projection? = nil, skipping skip: Int? = nil, readConcern: ReadConcern? = nil, collation: Collation? = nil) throws -> Future<Document?> {
        return try self.find(filter: query, sort: sort, projection: projection, readConcern: readConcern, collation: collation, skip: skip, limit: 1, timeout: nil, connection: nil).map { documents in
            return documents.next()
        }
    }
}

extension Future {
    func await() throws -> T {
        return try self.await(until: .seconds(60))
    }
}