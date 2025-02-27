import SPMUtility
import XCTest
@testable import TuistCore

final class SPMUtilityVersionTests: XCTestCase {
    func test_version_when_allTagsPresent() {
        XCTAssertEqual(Version(unformattedString: "11.2.3"), Version(11, 2, 3))
    }

    func test_version_when_moreTagsPresent() {
        XCTAssertNil(Version(unformattedString: "11.2.3.3"))
    }

    func test_version_when_noTagsPresent() {
        XCTAssertNil(Version(unformattedString: "."))
    }

    func test_version_when_patchTagOmitted() {
        XCTAssertEqual(Version(unformattedString: "11.2"), Version(11, 2, 0))
    }

    func test_version_when_minorTagOmitted() {
        XCTAssertEqual(Version(unformattedString: "11"), Version(11, 0, 0))
    }
}
