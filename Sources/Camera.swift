//
// FlatCamera - Frustum.swift
//
// Copyright (c) 2016 The FlatCamera authors.
// Licensed under MIT License.

import simd
import GLMath
import FlatCG

public struct Camera<P: Projection>: HasPose {

    public typealias PoseType = Pose3D

    public typealias PointType = Point3D

    public typealias RotationType = Quaternion

    public var pose: Pose3D

    fileprivate var _exposure = Exposure()

    public let projection: P

    /// The OpenGL style projection matrix.
    public var projectionMatrix: mat4 { return projection.matrix }

    fileprivate init (projection: P, pose: Pose3D) {
        self.projection = projection
        self.pose = pose
    }
}

// MARK: Constructor

extension Camera /* where P == Orthographic */ {

    /// Constructs a orthographic camera.
    public static func orthographic (
        width: Float,
        height: Float,
        near: Float,
        far: Float,
        pose: Pose3D = Pose3D()
    ) -> Camera<Orthographic>? {
        guard width > 0 else { return nil }
        guard height > 0 else { return nil }
        guard near > 0 else { return nil }
        guard far > near else { return nil }

        let proj = Orthographic(width, height, near, far)
        // SWIFT EVOLUTION:
        return Camera<Orthographic>(projection: proj, pose: pose)
    }
}

extension Camera /* where P == Perspective */ {

    /// Constructs a perspective projection camera with OpenGL style
    /// parameters.
    public static func perspective (
        aspect: Float,
        fov: Float,
        near: Float,
        far: Float,
        lens: Lens = .pinhole,
        pose: Pose3D = Pose3D()
    ) -> Camera<Perspective>? {
        guard aspect > 0 else { return nil }
        guard fov > 0 && fov < .pi else { return nil }
        guard far > near && near > 0 else { return nil }

        let proj = Perspective(aspect, tan(fov * 0.5), near, far, lens)
        // SWIFT EVOLUTION:
        return Camera<Perspective>(projection: proj, pose: pose)
    }

    /// Constructs a perspective projection camera.
    public static func perspective (
        filmSize: (Int, Int),
        focalLength: Float,
        far: Float,
        lens: Lens = .pinhole,
        pose: Pose3D = Pose3D()
    ) -> Camera<Perspective>? {
        let (w, h) = filmSize
        guard w > 0 && h > 0 else { return nil }
        guard focalLength > 0 else { return nil }
        guard far > focalLength else { return nil }

        let aspect = Float(w) / Float(h)
        let tangent = Float(h) * 0.5 / focalLength
        let proj = Perspective(aspect, tangent, focalLength, far, lens)
        return Camera<Perspective>(projection: proj, pose: pose)
    }
}

// MARK: Exposure

extension Camera {

    /// The maximum luminance possible with current exposure value.
    public var exposure: Float {
        let max_luminance = pow(2, _exposure.value) * 1.2
        return recip(max_luminance)
    }

    /// Exposure index in ISO.
    public var iso: Float {
        get { return _exposure.iso }
        set { _exposure.iso = newValue }
    }

    /// f-number, the ratio of the lens's focal length to the diameter of the 
    /// entrance pupil.
    public var fStop: Float {
        get { return _exposure.fStop }
        set { _exposure.fStop = newValue }
    }

    /// Shutter time in seconds, i.e., how long the aperture is opened.
    public var shutterTime: Float {
        get { return _exposure.shutterTime }
        set { _exposure.shutterTime = newValue }
    }

    public var exposureCompensation: Float {
        get { return _exposure.compensation }
        set { _exposure.compensation = newValue }
    }
}

// MARK: Projective

extension Camera {

    /// Returns the `Ray` originated from the center of the camera to
    /// the given sample `point`.
    public func ray(to point: Point2D) -> Ray {
        return projection.ray(to: point)
    }
}

// TODO: VR
