# Troubleshooting Guide

This guide covers common issues you might encounter when deploying and running the Spark History Server Helm chart.

## 🚨 Memory Issues

### OutOfMemoryError

**Symptoms:**
- Pod crashes with `OutOfMemoryError` in logs
- Slow UI loading or timeouts
- Frequent pod restarts
- History Server becomes unresponsive

**Root Causes:**
- `sparkDaemon.memory` too small for workload
- Too many retained applications in memory
- Large event logs consuming excessive memory
- RocksDB memory misconfiguration

**Solutions:**

#### 1. Increase Daemon Memory
Increase `sparkDaemon.memory` from default 4g to 8g or higher.

#### 2. Reduce Retained Applications  
Reduce `historyServer.retainedApplications` from 50 to 25 if memory constrained.

#### 3. Enable Hybrid Storage
Enable `historyServer.store.hybridStore` with RocksDB backend and ensure `maxMemoryUsage` < `sparkDaemon.memory`.

#### 4. Optimize Resource Limits
Increase `resources.requests.memory` and `resources.limits.memory` with headroom for spikes.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for complete configuration options and examples.

### RocksDB Startup Failures

**Symptoms:**
- `Failed to initialize RocksDB` error
- Pod stuck in `CrashLoopBackOff`
- Error: "Not enough memory to allocate RocksDB"

**Root Cause:**
- `sparkDaemon.memory` smaller than `hybridStore.maxMemoryUsage`

**Solution:**
Ensure `sparkDaemon.memory` is larger than `hybridStore.maxMemoryUsage` with 2GB+ headroom for JVM overhead.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for memory configuration examples.

## 🐌 Performance Issues

### Slow Event Log Loading

**Symptoms:**
- Long delays when clicking on applications
- UI shows "Loading..." for extended periods
- Timeouts when viewing application details
- High CPU usage during log parsing

**Solutions:**

#### 1. Increase Replay Threads
Increase `historyServer.fs.numReplayThreads` from default 4 to 8+ (rule of thumb: 1 thread per 2 CPU cores).

#### 2. Enable In-Progress Optimization
Enable `historyServer.fs.inProgressOptimization.enabled` for faster parsing of running applications.

#### 3. Optimize Storage Connections
Configure S3/ABFS connection pooling settings in `sparkConf` section.

#### 4. Increase CPU Resources
Increase `resources.requests.cpu` and consider removing CPU limits to allow bursting.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for performance tuning examples.

### High Memory Usage

**Symptoms:**
- Memory usage continuously increasing
- Pod eventually killed by OOM killer
- Slow garbage collection

**Solutions:**

#### 1. Tune JVM Settings
Optimize `sparkDaemon.javaOpts` with G1GC settings and add `MaxMetaspaceSize` limit.

#### 2. Implement Cache Eviction
Enable `historyServer.fs.cleaner` with appropriate `maxAge` and `maxNum` settings to cleanup old applications.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for JVM tuning and cleanup settings.

## 🔌 Storage Access Issues

### AWS S3 Authentication Failures

**Symptoms:**
- `Access Denied` errors in logs
- `Failed to list directory` messages
- `NoSuchBucket` errors
- IRSA authentication failures

**Solutions:**

#### 1. Verify IRSA Configuration
```bash
# Check if IRSA role is attached
kubectl describe sa spark-history-server -n spark-history-server

# Verify role ARN annotation
kubectl get sa spark-history-server -n spark-history-server -o yaml
```

#### 2. Check IAM Role Permissions
Ensure the IRSA role has `s3:GetObject` and `s3:ListBucket` permissions for your bucket and objects.

#### 3. Validate Trust Relationship
Verify the IAM role trust relationship allows the EKS OIDC provider and service account to assume the role.

### Azure ABFS Authentication Failures

**Symptoms:**
- `Authentication failed` errors
- `401 Unauthorized` responses
- Service principal authentication errors

**Solutions:**

#### 1. Verify Service Principal Permissions
```bash
# Check if service principal has Storage Blob Data Reader role
az role assignment list --assignee <client-id> --scope /subscriptions/<subscription>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>
```

#### 2. Validate Client Secret
```bash
# Test service principal authentication
az login --service-principal -u <client-id> -p <client-secret> --tenant <tenant-id>
```

#### 3. Check Storage Account Configuration
Verify `logStore.abfs` configuration matches your Azure storage account exactly and client secret is current.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for ABFS configuration examples.

### Local Storage Issues

**Symptoms:**
- `Permission denied` errors
- `No space left on device`
- Pod stuck in `Pending` state
- PVC not mounting

**Solutions:**

#### 1. Check PVC Status
```bash
kubectl get pvc -n spark-history-server
kubectl describe pvc <pvc-name> -n spark-history-server
```

#### 2. Verify Storage Class
Ensure `persistence.storageClass` exists in your cluster and `persistence.size` is appropriate.

#### 3. Check Permissions
Verify `podSecurityContext.fsGroup` matches volume ownership requirements.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for persistence and security context examples.

## 🌐 Network & Connectivity Issues

### Pod Cannot Start

**Symptoms:**
- Pod stuck in `ImagePullBackOff`
- `ErrImagePull` errors
- Cannot pull from ghcr.io

**Solutions:**

#### 1. Configure Image Pull Secrets
Configure `image.pullCredentials` section to authenticate with GitHub Container Registry.

#### 2. Verify Network Policies
Check if network policies block registry access with `kubectl get networkpolicies`.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for image pull credential examples.

### Ingress Not Working

**Symptoms:**
- 404 errors when accessing external URL
- Ingress controller logs show errors
- DNS resolution failures

**Solutions:**

#### 1. Check Ingress Controller
```bash
kubectl get ingress -n spark-history-server
kubectl describe ingress spark-history-server -n spark-history-server
```

#### 2. Verify Ingress Configuration
Ensure `ingress.ingressClassName` matches your controller and paths are correctly configured.

> **💡 Configuration Details:** See [values.yaml](../stable/spark-history-server/values.yaml) for ingress configuration examples.

#### 3. Check Service Endpoints
```bash
kubectl get svc spark-history-server -n spark-history-server
kubectl get endpoints spark-history-server -n spark-history-server
```

## 🔧 Configuration Issues

### Helm Chart Deployment Failures

**Symptoms:**
- `helm install` fails with validation errors
- Template rendering errors
- Resource conflicts

**Solutions:**

#### 1. Validate Configuration
```bash
# Dry run to check for issues
helm install spark-history-server kubedai/spark-history-server \
  --dry-run --debug \
  -f values.yaml

# Template validation
helm template spark-history-server kubedai/spark-history-server \
  -f values.yaml
```

#### 2. Check Resource Conflicts
```bash
# Look for existing resources
kubectl get all -n spark-history-server
kubectl get secrets -n spark-history-server
```

### Invalid Values Configuration

**Symptoms:**
- Configuration not taking effect
- Default values being used instead of custom ones
- Unexpected behavior

**Solutions:**

#### 1. Validate YAML Syntax
```bash
# Basic YAML validation (if yamllint is available)
yamllint values.yaml

# Alternative: use helm template to validate
helm template spark-history-server ./stable/spark-history-server -f values.yaml --dry-run
```

#### 2. Check Helm Values
```bash
# See effective values
helm get values spark-history-server -n spark-history-server

# Compare with defaults
helm show values kubedai/spark-history-server
```

## 📊 Debugging Commands

### Pod Debugging
```bash
# Get pod logs
kubectl logs -f deployment/spark-history-server -n spark-history-server

# Exec into pod
kubectl exec -it deployment/spark-history-server -n spark-history-server -- /bin/sh

# Check pod events
kubectl describe pod <pod-name> -n spark-history-server

# Get pod resource usage
kubectl top pod -n spark-history-server
```

### Configuration Debugging
```bash
# Check rendered ConfigMap
kubectl get configmap spark-history-server -n spark-history-server -o yaml

# Verify environment variables
kubectl exec deployment/spark-history-server -n spark-history-server -- env | grep SPARK

# Check if storage directory is accessible (basic connectivity test)
kubectl exec deployment/spark-history-server -n spark-history-server -- ls -la /opt/spark/logs
```

### Helm Debugging
```bash
# Check deployment status
helm status spark-history-server -n spark-history-server

# Get deployment history
helm history spark-history-server -n spark-history-server

# Rollback if needed
helm rollback spark-history-server 1 -n spark-history-server
```

## 🆘 Getting Help

If you're still experiencing issues:

1. **Check the logs** with the debugging commands above
2. **Search existing issues** on [GitHub Issues](https://github.com/kubedai/spark-history-server/issues)
3. **Create a new issue** with:
   - Complete error logs
   - Your `values.yaml` configuration
   - Kubernetes version and platform
   - Steps to reproduce the issue

## 📚 Additional Resources

- [Apache Spark History Server Documentation](https://spark.apache.org/docs/latest/monitoring.html)
- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Helm Troubleshooting](https://helm.sh/docs/faq/troubleshooting/)
- [Performance Tuning Guide](PERFORMANCE.md)