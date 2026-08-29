SHELL := /usr/bin/env bash

format:
	alejandra .

include terraform/Makefile
