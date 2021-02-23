import CoreData

@objc(CoreDataFeedImage)
public class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var desc: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
}
