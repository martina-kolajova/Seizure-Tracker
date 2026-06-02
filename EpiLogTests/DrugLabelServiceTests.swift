//
//  DrugLabelServiceTests.swift
//  Seizure Tracker
//
//  Created by Martina Kolajová on 04.01.2026.

import XCTest
@testable import Seizure_Tracker

final class DrugLabelServiceTests: XCTestCase {

    // MARK: - URLProtocol mock

    final class MockURLProtocol: URLProtocol {
        static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
        static var requestCount = 0

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            Self.requestCount += 1
            guard let handler = Self.requestHandler else {
                XCTFail("MockURLProtocol.requestHandler not set")
                return
            }

            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.requestCount = 0
    }

    // MARK: - Tests

    func testSearch_withShortTerm_clearsSuggestions_andDoesNotHitNetwork() async {
        let session = makeSession()
        let sut = await DrugLabelService(session: session, debounce: .milliseconds(0))

        await MainActor.run {
            sut.suggestions = [DrugSuggestion(displayName: "X", genericName: "X", brandName: "X")]
        }

        // If network is called, fail
        MockURLProtocol.requestHandler = { _ in
            XCTFail("Network should not be called for <2 chars")
            throw URLError(.badURL)
        }

        await MainActor.run {
            sut.search(term: "a") // trimmed count = 1
        }

                // Let any queued tasks (if any) run
        try? await Task.sleep(nanoseconds: 20_000_000)

        await MainActor.run {
            XCTAssertTrue(sut.suggestions.isEmpty)
        }
        XCTAssertEqual(MockURLProtocol.requestCount, 0)
    }

    func testFetch_parsesResults_dedupes_andSortsBrandPrefixFirst() async {
        let session = makeSession()
        let sut = await DrugLabelService(session: session, debounce: .milliseconds(0))

        let json = """
        {
          "results": [
            {"brand_name":"Keppra","generic_name":"Levetiracetam"},
            {"brand_name":"Keppra","generic_name":"Levetiracetam"},
            {"brand_name":"Xyrem","generic_name":"Sodium Oxybate"},
            {"generic_name":"Levetiracetam"}
          ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            // Verify endpoint + query items are correct
            XCTAssertEqual(request.url?.host, "api.fda.gov")
            XCTAssertEqual(request.url?.path, "/drug/ndc.json")

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, json)
        }

        // Term chosen so "Keppra" is a brand prefix match
        await sut.fetch(term: "kep")

        let suggestions = await MainActor.run { sut.suggestions }

        // Deduped: Keppra+Levetiracetam should appear once
        XCTAssertEqual(
            suggestions.filter { $0.brandName == "Keppra" && $0.genericName == "Levetiracetam" }.count,
            1
        )

        // Brand prefix first: Keppra should be before Xyrem / generic-only in this search term
        XCTAssertEqual(suggestions.first?.brandName, "Keppra")
    }

    func testFetch_whenErrorObjectPresent_returnsEmptySuggestions() async {
        let session = makeSession()
        let sut = await DrugLabelService(session: session, debounce: .milliseconds(0))

        let json = """
        {
          "error": {
            "code": "NOT_FOUND",
            "message": "No matches found!"
          }
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        await MainActor.run {
            sut.suggestions = [DrugSuggestion(displayName: "ShouldClear", genericName: nil, brandName: nil)]
        }

        await sut.fetch(term: "zz")

        let suggestions = await MainActor.run { sut.suggestions }
        XCTAssertTrue(suggestions.isEmpty)
    }

    func testFetch_whenNetworkThrows_setsEmptySuggestions() async {
        let session = makeSession()
        let sut = await DrugLabelService(session: session, debounce: .milliseconds(0))

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        await MainActor.run {
            sut.suggestions = [DrugSuggestion(displayName: "ShouldClear", genericName: nil, brandName: nil)]
        }

        await sut.fetch(term: "ke")

        let suggestions = await MainActor.run { sut.suggestions }
        XCTAssertTrue(suggestions.isEmpty)
    }
}
