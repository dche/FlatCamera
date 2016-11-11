//
// FlatCamera - Frustum.swift
//
// Copyright (c) 2016 The FlatCamera authors.
// Licensed under MIT License.

import simd
import GLMath
import FlatCG

/// The view frustum for view culling.
///
/// The new constructed frustum is in camera space.
public struct ViewFrustum {

    let top, bottom, left, right, near, far: Plane

    /// Constructs a `ViewFrustum` with given `camera`'s projection matrix.
    public init<T: Projection> (camera: Camera<T>) {
        let m = camera.projectionMatrix
        self.right =
            Plane(a: m[0, 3] - m[0, 0], b: m[1, 3] - m[1, 0], c: m[2, 3] - m[2, 0], d: m[3, 3] - m[3, 0])!
        self.left =
            Plane(a: m[0, 3] + m[0, 0], b: m[1, 3] + m[1, 0], c: m[2, 3] + m[2, 0], d: m[3, 3] + m[3, 0])!
        self.top =
            Plane(a: m[0, 3] - m[0, 1], b: m[1, 3] - m[1, 1], c: m[2, 3] - m[2, 1], d: m[3, 3] - m[3, 1])!
        self.bottom =
            Plane(a: m[0, 3] + m[0, 1], b: m[1, 3] + m[1, 1], c: m[2, 3] + m[2, 1], d: m[3, 3] + m[3, 1])!
        self.far =
            Plane(a: m[0, 3] - m[0, 2], b: m[1, 3] - m[1, 2], c: m[2, 3] - m[2, 2], d: m[3, 3] - m[3, 2])!
        self.near =
            Plane(a: m[0, 3] + m[0, 2], b: m[1, 3] + m[1, 2], c: m[2, 3] + m[2, 2], d: m[3, 3] + m[3, 2])!
    }

    /// Constructs a `ViewFrustum` with perspective projection parameters.
    public init? (aspect: Float, fov: Float, near: Float, far: Float) {
        guard aspect > 0 else { return nil }
        guard fov > 0 && fov < .pi else { return nil }
        guard far > near && near > 0 else { return nil }

        // http://www.iquilezles.org/www/articles/frustum/frustum.htm
        let ha = fov * 0.5
        let si = -sin(ha)
        let co = cos(ha)
        self.left = Plane(a: co, b: 0, c: si * aspect, d: 0)!
        self.right = Plane(a: -co, b: 0, c: si * aspect, d: 0)!
        self.top = Plane(a: 0, b: -co, c: si, d: 0)!
        self.bottom = Plane(a: 0, b: co, c: si, d: 0)!
        self.near = Plane(a: 0, b: 0, c: -1, d: -near)!
        self.far = Plane(a: 0, b: 0, c: 1, d: far)!
    }

    /// Constructs a `ViewFrustum` with orthographic projection parameters.
    public init? (width: Float, height: Float, near: Float, far: Float) {
        guard width > 0 else { return nil }
        guard height > 0 else { return nil }
        guard near > 0 else { return nil }
        guard far > near else { return nil }

        let hw = width * 0.5
        let hh = height * 0.5
        self.left = Plane(normal: Normal3D(1, 0, 0), t: hw)
        self.right = Plane(normal: Normal3D(-1, 0, 0), t: hw)
        self.top = Plane(normal: Normal3D(0, -1, 0), t: hh)
        self.bottom = Plane(normal: Normal3D(0, 1, 0), t: hh)
        self.far = Plane(normal: Normal3D(0, 0, 1), t: far)
        self.near = Plane(normal: Normal3D(0, 0, -1), t: -near)
    }

    /// Tests if the receiver contains given `point`.
    public func contains(point: Point3D) -> Bool {
        return point.inside(plane: top) &&
            point.inside(plane: bottom) &&
            point.inside(plane: left) &&
            point.inside(plane: right) &&
            point.inside(plane: near) &&
            point.inside(plane: far)
    }

    // TODO: Transformable.
}
