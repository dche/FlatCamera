//
// FlatCamera - Package.swift
//
// Copyright (c) 2016 The FlatCamera authors.
// Licensed under MIT License.

import PackageDescription

let package = Package(
    name: "FlatCamera",
    dependencies: [
        .Package(url: "../FlatCG",
                 majorVersion: 0),
    ]
)
