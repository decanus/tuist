import Foundation
import UIKit

public class StaticFrameworkResouces {
    private var bundle: Bundle {
        let path = Bundle.main.path(forResource: "StaticFrameworkResources", ofType: "bundle")
        
        guard let bundle = path.flatMap({ Bundle(path: $0) }) else {
            fatalError("StaticFrameworkResouces could not be loaded")
        }
        
        return bundle
    }
    
    public init() {
        
    }
    
    public var tuist: UIImage? {
        return UIImage(named: "tuist-bundle",
                       in: bundle,
                       compatibleWith: nil)
    }
}
