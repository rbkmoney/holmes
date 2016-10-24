#!/bin/bash

eval "shift 1 && cat <<EOF
$(<$1)
EOF"
