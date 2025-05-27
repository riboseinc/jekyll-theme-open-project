---
title: "DataForge CLI"
description: "Command-line interface for DataForge data processing"
featured: true
repo_url: "https://github.com/octocat/Hello-World"
repo_branch: "master"
tags:
  writtenin: ["Ruby", "Go"]
  audience: ["Developers", "Data Engineers"]
  interface: ["CLI", "API"]
---

# DataForge CLI

The DataForge CLI provides a powerful command-line interface for data processing and transformation tasks. Built for developers and data engineers who need efficient, scriptable data processing capabilities.

## Features

- **Batch Processing**: Process large datasets efficiently
- **Format Conversion**: Convert between JSON, XML, CSV, YAML
- **Schema Validation**: Validate data against predefined schemas
- **Pipeline Support**: Chain multiple processing operations
- **Plugin Architecture**: Extend functionality with custom plugins

## Installation

```bash
gem install dataforge-cli
```

## Quick Start

```bash
# Convert JSON to CSV
dataforge convert input.json --to csv --output data.csv

# Validate data against schema
dataforge validate data.json --schema schema.json

# Process data pipeline
dataforge pipeline --config pipeline.yml
```

## Documentation

Visit our [documentation site](https://docs.dataforge.example.com/cli) for comprehensive guides and API reference.
