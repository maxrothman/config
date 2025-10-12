set -euo pipefail

branch="$(git rev-parse --abbrev-ref HEAD)"

while : ; do
    res="$(gh pr checks --json=name,bucket "$branch")"
    [ $? = 0 ] || { echo "$res"; exit 1; }
    pending="$(<<< "$res"  jq -r 'map(select(.bucket=="pending")) | any')"
    if [ "$pending" = "false" ]; then
        if [ "$(<<< "$res" jq -r 'map(select(.bucket=="fail")) | any')" = "true" ]; then
            echo "Failed checks: $(<<< "$res" jq -r '.[] | select(.bucket=="fail") | .name' | sed 's/ //g' | tr '\n' ' ')"
            exit 1
        else
            sleep 60
            echo "All checks passed!"
            exit 0
        fi
    else
        echo "Pending checks: $(<<< "$res" jq -r '.[] | select(.bucket=="pending") | .name' | sed 's/ //g' | tr '\n' ' ')"
        sleep 30
    fi
done
