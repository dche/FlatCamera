//
// FlatCamera - Frustum.swift
//
// Copyright (c) 2016 The FlatCamera authors.
// Licensed under MIT License.

import simd

// - see: SIGGRAPH 2014, "Moving Frostbite to Physically Based Rendering".
struct Exposure {

    var fStop: Float = 2

    var shutterTime: Float = 1 / 250

    var iso: Float = 100

    var compensation: Float = 0

    var value: Float {
        return log2(fStop * fStop / shutterTime * 100 / iso)
    }
}
