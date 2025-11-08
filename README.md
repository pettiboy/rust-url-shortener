# Rust URL Shortener

## For testing

```zsh
watchexec -e rs -r cargo run
```

## SQLx CLI

[docs](https://github.com/launchbadge/sqlx/blob/main/sqlx-cli/README.md)

creating migration

```zsh
sqlx migrate add create_links_table
```

then add your migration to the `.sql` file

```zsh
sqlx migrate run
```
