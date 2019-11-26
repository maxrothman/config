# Script to prefix alembic migrations so they order correctly with ls
function alembic-prefix() {
  local fname migrations_dir last_num
  migrations_dir="$(git rev-parse --show-toplevel)"/alembic/versions
  
  last_num="$(find -E "$migrations_dir" -type f \
      -regex '^'"$migrations_dir"/'[0-9]+_[0-9a-zA-Z_]+.py' -name '*.py' |
      sort -nr | head -n1 | sed -r 's|^.*/([0-9]+)_.*$|\1|')"

  find -E "$migrations_dir" -type f \
      -not -regex '^'"$migrations_dir"/'[0-9]+_[0-9a-zA-Z_]+.py' -name '*.py' \
      -exec stat -c '%Y %n' '{}' \; |
    sort -n | cut -d ' ' -f2 |
    while read fname; do
      rename --subst "$migrations_dir"/ "$migrations_dir"/$((++last_num))_ "$fname"*
      basename -a "$migrations_dir"/*"$(basename "$fname")"*
    done
}
