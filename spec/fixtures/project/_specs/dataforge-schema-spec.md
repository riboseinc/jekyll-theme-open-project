---
title: "DataForge Schema Specification"
description: "Comprehensive schema specification for DataForge data structures"
featured: true
spec_source:
  git_repo_url: "https://github.com/octocat/Hello-World"
  git_repo_branch: "master"
tags:
  audience: ["Developers", "Data Architects"]
  status: ["Draft", "Under Review"]
  type: ["Technical Specification", "API Documentation"]
---

# DataForge Schema Specification

The DataForge Schema Specification defines a standardized format for describing data structures, validation rules, and transformation mappings within the DataForge ecosystem.

## Overview

This specification provides:

- **Schema Definition Language**: JSON-based schema definition format
- **Validation Rules**: Comprehensive validation rule syntax
- **Type System**: Rich type system for data validation
- **Transformation Mappings**: Schema-to-schema transformation definitions

## Schema Format

### Basic Structure

```json
{
  "$schema": "https://schemas.dataforge.example.com/v1/schema.json",
  "id": "https://schemas.dataforge.example.com/user-profile.json",
  "title": "User Profile Schema",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "email": {
      "type": "string",
      "format": "email"
    },
    "age": {
      "type": "integer",
      "minimum": 0,
      "maximum": 150
    }
  },
  "required": ["name", "email"]
}
```

### Validation Rules

The specification supports various validation rules:

- **Type Validation**: Basic type checking (string, number, boolean, etc.)
- **Format Validation**: Email, URL, date, time formats
- **Range Validation**: Min/max values for numbers and strings
- **Pattern Validation**: Regular expression matching
- **Custom Validation**: User-defined validation functions

## Implementation

Reference implementations are available for:

- JavaScript/Node.js
- Python
- Ruby
- Go
- Java

## Version History

- **v1.0**: Initial specification release
- **v1.1**: Added transformation mappings
- **v1.2**: Enhanced validation rules and custom validators
