# use-the-latest-greatest-sql-skill

Snowflake Cortex Code skill for refactoring SQL with modern, generally available (GA) Snowflake functions and commands.

## What you are installing

Skill folder name:
- `use-the-latest-greatest-sql-skill`

Required files:
- `SKILL.md`
- `references/ga-sql-improvements.md`

## Install locations

Cortex loads skills from (highest to lower priority):
- Project scope: `.cortex/skills/<skill-name>/`
- User scope (global): `~/.snowflake/cortex/skills/<skill-name>/`

Use user scope if you want the skill available across all projects.

## Install steps (global/user scope)

1. Create the target directory:
```bash
mkdir -p ~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill
```

2. Copy the artefacts into that folder:
```bash
cp -R use-the-latest-greatest-sql-skill/* ~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill/
```

3. Verify files exist:
```bash
find ~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill -maxdepth 3 -type f | sort
```

Expected minimum output:
- `~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill/SKILL.md`
- `~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill/references/ga-sql-improvements.md`

## Validate in Cortex

List available skills:
```bash
/skill list
```
or
```bash
cortex skill list
```

## Use the skill

Example invocation:
```text
$use-the-latest-greatest-sql-skill refactor this SQL and avoid preview features
```

## Update / reinstall

Overwrite with latest artefacts:
```bash
cp -R use-the-latest-greatest-sql-skill/* ~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill/
```

## Uninstall

```bash
rm -rf ~/.snowflake/cortex/skills/use-the-latest-greatest-sql-skill
```

## Troubleshooting

- Skill not listed: confirm folder name exactly matches `use-the-latest-greatest-sql-skill`.
- Skill listed but behaviour is old: re-copy artefacts and restart the Cortex session.
- Conflicts across scopes: check project skill vs global skill and sync the version you want.
