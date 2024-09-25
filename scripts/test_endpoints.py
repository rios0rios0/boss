#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
Endpoint testing script

This script tests a list of endpoints to ensure they are working as expected.
"""

import json
import re
from dataclasses import dataclass
from enum import Enum
from typing import Any, List, Optional

import requests


class ExpectedResponseType(Enum):
    VALID_JSON = 1
    JSON_FIELD = 2
    REGEX = 3


@dataclass
class TestCase:
    description: str
    url: str
    expected_status: int
    expected_response_type: ExpectedResponseType
    expected_response_value: Any = None
    extra_headers: Optional[dict] = None


def test_endpoint(
    test_case: TestCase,
) -> bool:
    print(f"Running test: {test_case.description}...", end=" ")

    # Launch the request
    try:
        response = requests.get(test_case.url, headers=test_case.extra_headers)
        http_status = response.status_code
        response_body = response.text

    except requests.ConnectionError:
        print("Test failed: connection error")
        return False

    except requests.RequestException as e:
        print(f"Test failed: {str(e)}")
        return False

    # Check the status code
    if http_status != test_case.expected_status:
        print(
            "Test failed: Expected status {} but got {}".format(
                test_case.expected_status, http_status
            )
        )
        return False

    # Validate the response body based on the expected response type
    # Check if the response body is valid JSON
    response_json = {}
    if (
        test_case.expected_response_type == ExpectedResponseType.VALID_JSON
        or test_case.expected_response_type == ExpectedResponseType.JSON_FIELD
    ):
        try:
            response_json = response.json()
        except json.JSONDecodeError:
            print("Test failed: Response body is not valid JSON")
            print("Response body:")
            print(response_body)
            return False

    # Check if the response contains a field with a specific value
    if test_case.expected_response_type == ExpectedResponseType.JSON_FIELD:
        if not isinstance(test_case.expected_response_value, dict):
            print("Test failed: Expected response value is not a dictionary")
            return False

        # Check if the expected keys and values are in the response
        for key, value in test_case.expected_response_value.items():
            if key not in response_json:
                print(f"Test failed: Expected key {key} not found in response")
                return False

            # Check if the value is as expected
            if response_json[key] != value:
                print(
                    "Test failed: Expected {} to be {} but got {}".format(
                        key, value, response_json[key]
                    )
                )
                return False

    elif test_case.expected_response_type == ExpectedResponseType.REGEX:
        # Use regex to match the response body
        if not re.search(test_case.expected_response_value, response_body):
            print("Test failed: Response body does not match expected pattern")
            print("Expected pattern:")
            print(test_case.expected_response_value)
            print("Actual response:")
            print(response_body)
            return False

    print("passed")
    return True


# Define test cases
test_cases: List[TestCase] = [
    TestCase(
        "Example API with valid JSON",
        "http://example.com/endpoint",
        200,
        ExpectedResponseType.VALID_JSON,
    ),
    TestCase(
        "Example API with custom header",
        "http://example.com/endpoint",
        204,
        ExpectedResponseType.REGEX,
        ".*",
        {"Custom-Header": "value"},
    ),
    TestCase(
        "Example API with JSON field",
        "http://example.com/endpoint",
        401,
        ExpectedResponseType.JSON_FIELD,
        {"message": "No API key found in request"},
    ),
]

# Run tests
for test_case in test_cases:
    test_endpoint(test_case)
