//
// FlatCamera - Frustum.swift
//
// Copyright (c) 2016 The FlatCamera authors.
// Licensed under MIT License.

import simd
import GLMath
import FlatCG

public protocol Projection {

    /// The OpenGL style projection matrix.
    var matrix: mat4 { get }

    /// Shoots a ray to a sample `point` at view plane.
    ///
    /// - parameter point: The sample point. The coordinate should be
    /// normalized in the range [-1, 1].
    /// - returns: The direction of the ray in the camera sapce.
    func ray(to point: Point2D) -> Ray
}

public struct Orthographic: Projection {

    public let width: Float
    public let height: Float
    public let matrix: mat4

    init (_ width: Float, _ height: Float, _ near: Float, _ far: Float) {
        assert(width > 0 && height > 0 && far > near && near > 0)

        self.width = width
        self.height = height
        self.matrix = mat4(
            2 / width, 0, 0, 0,
            0, 2 / height, 0, 0,
            0, 0, -2 / (far - near), 0,
            0, 0, -(far + near) / (far - near), 1)
    }

    public func ray(to point: Point2D) -> Ray {
        let o = Point3D(width * point.x * 0.5, height * point.y * 0.5, 0)
        return Ray(origin: o, direction: Normal3D(0, 0, -1))
    }
}

public struct Perspective: Projection {

    public let matrix: mat4
    let lens: Lens
    let aspect: Float
    // Normalized distance between center of the lens to the center of the 
    // image plane.
    let focalLength: Float

    init (_ aspect: Float, _ tangent: Float, _ near: Float, _ far: Float, _ lens: Lens) {
        assert(aspect > 0 && tangent > 0 && far > near && near > 0)

        let d = recip(tangent)
        let a = -(far + near) / (far - near)
        let b = -far * near * 2 / (far - near)
        let pm = mat4(
            d / aspect, 0, 0, 0,
            0, d, 0, 0,
            0, 0, a, -1,
            0, 0, b, 0)

        self.matrix = pm
        self.lens = lens
        self.aspect = aspect
        self.focalLength = d
    }

    public func ray(to point: Point2D) -> Ray {
        switch self.lens {
        case .pinhole:
            let d = Normal3D(point.x * aspect, point.y, -self.focalLength)
            return Ray(origin: Point3D.origin, direction: d)
        }
    }
}
