#!/bin/bash
set -e

PROFILE="lucas-leyva-be"

echo "=== Starting/restoring minikube cluster: $PROFILE ==="
minikube start -p "$PROFILE" --driver=docker --cpus=2 --memory=2900 2>&1

echo ""
echo "=== Applying K8s manifests ==="
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f ms-pedidos.yaml
kubectl apply -f ms-productos.yaml

echo ""
echo "=== Waiting for pods ==="
kubectl wait --for=condition=ready pod -n ms-pedidos-ns -l app=ms-pedidos --timeout=120s
kubectl wait --for=condition=ready pod -n ms-pedidos-ns -l app=ms-productos --timeout=120s

echo ""
echo "=== Pods ==="
kubectl get pods -n ms-pedidos-ns

echo ""
echo "=== Services ==="
kubectl get svc -n ms-pedidos-ns

echo ""
echo "=== Testing M2 (Productos) ==="
kubectl port-forward -n ms-pedidos-ns svc/ms-productos 8081:8081 &
PF2_PID=$!
sleep 2
curl -s http://localhost:8081/actuator/health && echo " [M2 OK]" || echo " [M2 FAIL]"
kill $PF2_PID 2>/dev/null

echo ""
echo "=== Testing M1 (Pedidos) ==="
kubectl port-forward -n ms-pedidos-ns svc/ms-pedidos 8082:8082 &
PF1_PID=$!
sleep 2
curl -s http://localhost:8082/actuator/health && echo " [M1 OK]" || echo " [M1 FAIL]"
kill $PF1_PID 2>/dev/null

echo ""
echo "=== Ready! ==="
echo "  Port-forward M2 (Productos): kubectl port-forward -n ms-pedidos-ns svc/ms-productos 8081:8081"
echo "  Port-forward M1 (Pedidos):   kubectl port-forward -n ms-pedidos-ns svc/ms-pedidos 8082:8082"
