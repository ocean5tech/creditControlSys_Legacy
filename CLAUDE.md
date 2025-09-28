# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

This repository is for a project that will be developed through iterative requirements gathering and documentation.

## Requirements Gathering Process

When the user discusses requirements, Claude should:
1. Listen to and understand each requirement as it's presented
2. Categorize requirements into: Business Requirements, Technical Requirements, and Project Requirements
3. Update the requirements document in the `requirements/` folder with new information
4. Maintain a comprehensive requirements document that evolves with the discussion

## Common Commands

*To be filled in when build system is established*

## Architecture

*To be filled in when codebase structure is established*

## Development Notes

*To be filled in with project-specific guidance as development progresses*

## Critical Development Constraints

**IMPORTANT: The following rules MUST be followed at all times:**

1. **Port Restriction**: 禁止占用任何新的端口 - Only use existing allocated ports (4000-4002)
2. **Software Installation**: 禁止安装任何新的软件 - Use only existing installed software
3. **Container Images**: 禁止安装任何新的podman image - Use only existing container images
4. **Initialization Operations**: 禁止任何初始化操作 - Do not initialize databases, create new schemas, or perform setup operations
5. **Customer Authorization**: 没有经过客户运行 - All operations requiring new resources must be approved by customer first

## Required Behavior When Missing Resources

When Claude cannot find needed software, configurations, or information:
1. **STOP** the current operation immediately
2. **DO NOT** attempt workarounds or alternatives
3. **ASK** the customer explicitly for guidance or resources
4. **WAIT** for customer approval before proceeding

## Existing Resources to Use

- Database: Use existing PostgreSQL connection (refer to development-status.md Milestone 1,2)
- Ports: 4000-4002 only (already allocated)
- Containers: Use existing credit-control-legacy containers
- Software: Use existing installed packages and dependencies