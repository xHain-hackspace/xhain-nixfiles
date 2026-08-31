SHELL := /usr/bin/env bash

format:
	nix fmt

include terraform/Makefile
