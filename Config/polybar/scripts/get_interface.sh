#!/bin/bash

# Devuelve la primera interfaz con IP válida (que no sea loopback)
ip -o -4 addr list | grep -v '127.0.0.1' | awk '{print $2}' | head -n1
