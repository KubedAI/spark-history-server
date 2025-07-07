# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-07-07

### Added
- **Configurable SPARK_DAEMON_MEMORY**: New `sparkDaemon` configuration section to prevent RocksDB startup failures
- **Local Storage Support**: Complete support for air-gapped and on-premises deployments
- **Advanced Caching**: Optimized cache configuration with 30GB PVC and 50 retained applications
- **Performance Optimizations**: CPU bursting support and intelligent memory management
- **Hybrid Store Integration**: Enhanced RocksDB configuration with memory awareness

### Changed
- **Memory Configuration**: `sparkDaemon.memory` is now configurable and positioned near `hybridStore` settings
- **Resource Allocation**: Removed CPU limits to allow bursting, increased memory defaults
- **Cache Strategy**: Optimized `retainedApplications` from 100 to 50 with larger PVC (30GB)
- **Thread Configuration**: Enhanced `numReplayThreads` configuration for better parallelism
- **Health Checks**: Improved liveness and readiness probe configurations for production use

### Fixed
- **Security Vulnerabilities**: Updated Jackson dependencies to 2.18.1 (CVE-2023-35116, CVE-2024-52504)
- **RocksDB Memory Issues**: Configurable daemon memory prevents startup failures when RocksDB > 4GB
- **Template Rendering**: Fixed environment variable injection in both deployment and statefulset templates
- **Test Coverage**: Updated all unit tests to reflect new configurations and optimizations

### Security
- **Jackson Update**: Resolved high and moderate severity CVEs in Jackson library
- **Memory Isolation**: Better separation between JVM and RocksDB memory allocation
- **Container Security**: Enhanced security context with read-only filesystem and non-root execution

### Performance
- **JVM Tuning**: Optimized G1GC settings with string deduplication and compressed OOPs
- **Storage Optimization**: Enhanced S3/ABFS connection pooling for high-throughput scenarios
- **Thread Pool**: Configurable replay threads (default 4) for faster event log processing
- **Memory Management**: Intelligent cache eviction and retention strategies

### Documentation
- **Professional README**: Complete rewrite with expert-level configuration examples
- **Troubleshooting Guide**: Comprehensive problem-solving documentation
- **Performance Tuning**: Detailed optimization guidance for different workload sizes
- **Security Best Practices**: Production-ready security configurations

## [1.4.0] - 2024-12-15

### Added
- **Azure ADLS Gen2 Support**: Complete integration with Azure Blob File System (ABFS)
- **Multi-Architecture**: Support for both AMD64 and ARM64 architectures
- **Enhanced Security**: Comprehensive security configurations and best practices
- **IRSA Integration**: AWS IAM Roles for Service Accounts for secure S3 access

### Changed
- **Container Images**: Multi-arch builds published to GitHub Container Registry
- **Authentication**: OAuth2 support for Azure storage backends
- **Performance**: Baseline performance optimizations for medium-scale deployments

### Fixed
- **Storage Backend**: Improved reliability for Azure storage configurations
- **Authentication**: Better error handling for service principal authentication

## [1.3.0] - 2024-11-20

### Added
- **Hybrid Storage**: RocksDB-based hybrid storage for massive scale deployments
- **Persistent Volumes**: Support for persistent storage with configurable storage classes
- **Advanced Configuration**: Comprehensive Spark History Server configuration options

### Changed
- **Memory Management**: Enhanced memory allocation strategies
- **Storage Backend**: Improved S3 configuration with connection pooling

### Fixed
- **Stability**: Better handling of large event logs and memory pressure

## [1.2.0] - 2024-10-10

### Added
- **Health Checks**: Comprehensive liveness and readiness probes
- **Resource Management**: Configurable CPU and memory requests/limits
- **Ingress Support**: Built-in ingress configuration for external access

### Changed
- **Default Configuration**: Optimized default values for better out-of-box experience
- **Documentation**: Enhanced configuration documentation and examples

### Fixed
- **Pod Startup**: Improved startup time and reliability
- **Configuration**: Better validation of user-provided configurations

## [1.1.0] - 2024-09-05

### Added
- **Service Account**: Configurable service account with annotation support
- **Security Context**: Enhanced pod and container security configurations
- **Environment Variables**: Support for custom environment variables

### Changed
- **Image Management**: Improved image pull secret management
- **Configuration Structure**: Better organization of values.yaml

### Fixed
- **S3 Access**: Improved S3 access patterns and error handling
- **Chart Dependencies**: Better dependency management and versioning

## [1.0.0] - 2024-08-01

### Added
- **Initial Release**: Complete Spark History Server Helm chart
- **S3 Support**: Native Amazon S3 integration with IRSA
- **GitHub Container Registry**: Multi-platform container images
- **Production Ready**: Security, monitoring, and performance configurations

### Features
- Apache Spark History Server deployment on Kubernetes
- AWS S3 event log storage with IRSA authentication
- Configurable resource allocation and scaling
- Comprehensive monitoring and observability
- Production-grade security configurations
- Multi-platform container support (AMD64/ARM64)

---

## Release Process

### Versioning Strategy
- **Major** (X.0.0): Breaking changes, significant architecture updates
- **Minor** (X.Y.0): New features, enhancements, non-breaking changes  
- **Patch** (X.Y.Z): Bug fixes, security updates, documentation improvements

### Release Checklist
- [ ] Update version in `Chart.yaml`
- [ ] Update `appVersion` if container image changes
- [ ] Update this changelog with all changes
- [ ] Test deployment on multiple Kubernetes versions
- [ ] Validate all storage backends (S3, ABFS, Local)
- [ ] Run complete test suite (`task unittest`)
- [ ] Update documentation if needed
- [ ] Create GitHub release with release notes
- [ ] Publish updated Helm chart to repository

### Supported Versions
| Version | Support Status | End of Life |
|---------|---------------|-------------|
| 1.5.x   | ✅ Active     | TBD         |
| 1.4.x   | ✅ Active     | 2025-06-01  |
| 1.3.x   | ⚠️ Maintenance | 2025-03-01  |
| 1.2.x   | ❌ End of Life | 2024-12-01  |

### Security Updates
Security vulnerabilities are addressed in:
- Latest major/minor version (immediate patch)
- Previous minor version (within 30 days)
- Critical vulnerabilities may receive patches for older versions

For security reports, please email security@kubedai.io or create a private GitHub security advisory.

## Contributing to Changelog

When contributing changes, please update this changelog following these guidelines:

1. **Add unreleased changes** under `## [Unreleased]` section
2. **Use semantic categories**: Added, Changed, Deprecated, Removed, Fixed, Security
3. **Include GitHub issue/PR numbers** where applicable
4. **Write clear, user-focused descriptions** of changes
5. **Include breaking change warnings** for major version updates

Example entry:
```markdown
### Added
- New feature XYZ that enables ABC functionality (#123)

### Fixed  
- Resolved issue with DEF causing GHI error in production environments (#456)

### Security
- Updated dependency XYZ to address CVE-2024-12345 (#789)
```