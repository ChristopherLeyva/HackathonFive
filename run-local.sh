#!/bin/bash
set -e

echo "=== Starting MicroProductos (M2) on :8081 ==="
(cd /Users/Christopher/HackathonFiveM2 && mvn spring-boot:run > /tmp/m2.log 2>&1) &
M2_PID=$!
echo "  PID: $M2_PID"

echo "=== Starting MicroPedidos (M1) on :8082 ==="
(cd /Users/Christopher/HackathonFiveM1 && mvn spring-boot:run > /tmp/m1.log 2>&1) &
M1_PID=$!
echo "  PID: $M1_PID"

echo ""
echo "Waiting for M2..."
sleep 25
echo "Waiting for M1..."
sleep 15

echo ""
echo "=== Testing ==="
echo "M2 health:"
curl -s http://localhost:8081/actuator/health
echo ""
echo "M1 health:"
curl -s http://localhost:8082/actuator/health
echo ""

echo "=== Running ==="
echo "  M2 logs: tail -f /tmp/m2.log"
echo "  M1 logs: tail -f /tmp/m1.log"
echo "  Stop:    kill $M1_PID $M2_PID"
