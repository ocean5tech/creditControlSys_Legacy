# Project Requirements Document

## Business Requirements

### Client Context
- **Client**: Insurance company
- **System**: Credit Control (part of Operations system)
- **Business Goal**: Prove that AI tools can reliably perform code migration/refactoring from legacy systems to modern architecture

### Migration Objective
- **Current State**: JDK5 + Struts + JSP (online system)
- **Target State**: SpringBoot + React (modern frontend/backend separation)
- **Purpose**: Build POC to demonstrate feasibility and reliability of AI-assisted code transformation

## Technical Requirements

### Legacy System Architecture
- **Technology Stack**: JDK5 + Struts + JSP
- **Database**: PostgreSQL
- **System Type**: Online system with batch processing capabilities

### System Features to Implement
- **Web Interface**: 7-8 web pages
- **Backend Processing**: Complete backend logic implementation
- **Database Operations**: Full CRUD operations on PostgreSQL
- **Batch Processing**: Nighttime batch jobs for data summarization
- **Logging System**: Comprehensive logging throughout the application

### Business Scenarios to Implement
- **Primary Workflow**: Customer credit query → database retrieval → results display → user modifications → TableA updates → confirmation → batch processing (TableA to TableB summarization) → report generation
- **Multiple Scenarios**: Create several business scenarios covering different aspects of credit control operations

### Target Architecture Requirements
- **Backend**: SpringBoot framework
- **Frontend**: React.js (separate from backend)
- **Architecture**: Full frontend/backend separation
- **Database**: Maintain PostgreSQL compatibility
- **Functionality**: Identical business logic and operations as legacy system

### Analysis and Documentation
- **Static Code Analysis**: Use available tools for comprehensive code analysis
- **Migration Mapping**: Focus on functionality mapping between old and new systems
- **Testing**: Comprehensive test suites for both legacy and modern systems

## Project Requirements

### Phase 1: Legacy System Development
- Build complete Credit Control system using JDK5 + Struts + JSP architecture
- Implement all specified features and business scenarios
- Create comprehensive test suite and documentation

### Phase 2: System Analysis
- Use Claude Code for thorough code analysis
- Apply static code analysis tools as needed
- Generate migration documentation with detailed functionality mapping

### Phase 3: Code Transformation
- Transform legacy codebase to SpringBoot + React architecture
- Maintain identical business functionality
- Implement frontend/backend separation

### Phase 4: Validation and Comparison
- Execute identical test suites on both systems
- Compare results to validate migration reliability
- Document findings to prove AI-assisted migration feasibility

---

*This document will be continuously updated as requirements are discussed*