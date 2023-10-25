// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -swift-version 5 -emit-module-path %t/SerializedStruct.swiftmodule -module-name SerializedStruct %S/Inputs/SerializedStruct.swift

// RUN: %target-swift-frontend %s -emit-sil -o /dev/null -verify -disable-availability-checking -swift-version 6 -I %t
// RUN: %target-swift-frontend %s -emit-sil -o /dev/null -verify -disable-availability-checking -swift-version 6 -I %t -enable-experimental-feature SendNonSendable

// REQUIRES: concurrency
// REQUIRES: asserts

// This test ensures that, when loading a Swift 5 serialized module with
// a global-actor annotation that is an error in Swift 6, but only a warning
// in Swift 5, then we do not reject the import as an error.

import SerializedStruct // expected-warning {{add '@preconcurrency' to treat 'Sendable'-related errors from module 'SerializedStruct' as warnings}}

// use it to force the right checks happen.
func test() async -> Int {
  let x = MySerializedStruct()
  return await x.counter // expected-warning {{non-sendable type 'MySerializedStruct' passed in implicitly asynchronous call to main actor-isolated property 'counter' cannot cross actor boundary}}
}
