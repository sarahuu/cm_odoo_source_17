#!/bin/bash
set -eo pipefail

echo "=== Debug Info ==="
echo "Current user: $(whoami)"
echo "Checking if odoo user exists..."
grep odoo /etc/passwd || echo "Odoo user NOT found!"
echo "=================="

# Check for database availability if using PostgreSQL
if [ "$1" = "odoo" ] && [ "$2" != "shell" ]; then
    echo "Checking if database is ready..."
    python3 /usr/local/bin/wait-for-psql.py
fi

# Handle the command passed to the script
case "$1" in
    "odoo")
        shift
        if [[ "$1" == "scaffold" ]]; then
            exec odoo "$@"
        else
            # Only wait for psql if not running scaffold
            wait-for-psql.py --timeout=30
            exec odoo "$@"
        fi
        ;;
    -*)
        # For commands starting with - (like --workers)
        wait-for-psql.py --timeout=30
        exec odoo "$@"
        ;;
    *)
        # For all other commands
        exec "$@"
        ;;
esac

exit 1