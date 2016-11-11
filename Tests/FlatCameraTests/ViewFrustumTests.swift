
import XCTest
import simd
import GLMath
import FlatCG
@testable import FlatCamera

class ViewFrustumTests: XCTestCase {

    func testPerspectiveProjectionFromMatrix() {
        // SWIFT EVOLUTION: Should not specify type parameter.
        let cam =
            Camera<Perspective>.perspective(aspect: 1, fov: .half_pi, near: 1, far: 100)!
        let f = ViewFrustum(camera: cam)
        XCTAssertFalse(f.contains(point: Point3D.origin))
        XCTAssert(f.contains(point: Point3D(0, 0, -50)))
        XCTAssert(f.contains(point: Point3D(0, 0, -1 - .epsilon)))
        XCTAssert(f.contains(point: Point3D(-1, -1, -1.001)))
        XCTAssertFalse(f.contains(point: Point3D(-1.1, -1.1, -1.001)))
        XCTAssert(f.contains(point: Point3D(1, 1, -1.001)))
        XCTAssertFalse(f.contains(point: Point3D(1.1, 1.1, -1.001)))
        XCTAssert(f.contains(point: Point3D(0, 0, -100.0 + 0.001)))
        XCTAssertFalse(f.contains(point: Point3D(vec3(-99))))
        XCTAssert(f.contains(point: Point3D(-99, -99, -99.999)))
        XCTAssertFalse(f.contains(point: Point3D(vec3(-100.001))))
        XCTAssert(f.contains(point: Point3D(99, 99, -99.999)))
        XCTAssertFalse(f.contains(point: Point3D(0, 0, -100.1)))
    }

    func testOrothoProjectionMatrix() {
        let cam =
            Camera<Orthographic>.orthographic(width: 2, height: 2, near: 1, far: 100)!
        let f = ViewFrustum(camera: cam)
        XCTAssertFalse(f.contains(point: Point3D.origin))
        XCTAssert(f.contains(point: Point3D(0, 0, -50)))
        XCTAssert(f.contains(point: Point3D(0, 0, -1.0 - 0.001)))
        XCTAssertFalse(f.contains(point: Point3D(0, 0, -1.0 + 0.001)))
        XCTAssertFalse(f.contains(point: Point3D(-1, -1, -1.001)))
        XCTAssert(f.contains(point: Point3D(-0.999, -0.999, -1.001)))
        XCTAssertFalse(f.contains(point: Point3D(1, 1, -1.001)))
        XCTAssert(f.contains(point: Point3D(0.999, 0.999, -1.001)))
    }

    func testConstructionFromParams() {
        let pcam =
            Camera<Perspective>.perspective(aspect: 1, fov: .half_pi, near: 1, far: 100)!
        var f0 = ViewFrustum(camera: pcam)
        var f1 = ViewFrustum(aspect: 1, fov: .half_pi, near: 1, far: 100)!

        XCTAssert(f0.left.normal.vector.isClose(to: f1.left.normal.vector, tolerance: 1e-5))
        XCTAssert(f0.left.t.isClose(to: f1.left.t, tolerance: 1e-5))
        XCTAssert(f0.far.normal.vector.isClose(to: f1.far.normal.vector, tolerance: 1e-5))
        XCTAssert(f0.far.t.isClose(to: f1.far.t, tolerance: 1e-5))

        let ccam =
            Camera<Orthographic>.orthographic(width: 2, height: 2, near: 1, far: 100)!
        f0 = ViewFrustum(camera: ccam)
        f1 = ViewFrustum(width: 2, height: 2, near: 1, far: 100)!

        XCTAssert(f0.left.normal.vector.isClose(to: f1.left.normal.vector, tolerance: 1e-5))
        XCTAssert(f0.left.t.isClose(to: f1.left.t, tolerance: 1e-5))
        XCTAssert(f0.far.normal.vector.isClose(to: f1.far.normal.vector, tolerance: 1e-5))
        XCTAssert(f0.far.t.isClose(to: f1.far.t, tolerance: 1e-5))
    }
}
