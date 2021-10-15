#!/bin/bash -eu

flutter pub get

flutter test --coverage
