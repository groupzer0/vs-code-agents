# Markdown Linting Requirements

This document defines the markdown linting standards for the vs-code-agents repository.

## Purpose

Consistent markdown formatting ensures:

- Proper syntax highlighting in code examples
- Clean rendering across GitHub, IDEs, and documentation tools
- Reduced commit failures from linting errors
- Professional documentation quality

## Configuration

The repository uses [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) with configuration in `.markdownlint-cli2.yaml`.

### Running the Linter

```bash
# Check all markdown files
npx markdownlint-cli2 "**/*.md"

# Fix auto-fixable issues
npx markdownlint-cli2 --fix "**/*.md"
```

## Required Rules

### MD040: Fenced Code Language

Every fenced code block **must** include a language identifier.

```markdown
<!-- Wrong -->
` ` `
public void Example() { }
` ` `

<!-- Correct -->
` ` `csharp
public void Example() { }
` ` `
```

### MD031: Blank Lines Around Fences

Fenced code blocks must be surrounded by blank lines.

```markdown
<!-- Wrong -->
Some text
` ` `csharp
code
` ` `
More text

<!-- Correct -->
Some text

` ` `csharp
code
` ` `

More text
```

### MD032: Blank Lines Around Lists

Lists must be surrounded by blank lines.

```markdown
<!-- Wrong -->
Introduction text
- Item 1
- Item 2
Conclusion text

<!-- Correct -->
Introduction text

- Item 1
- Item 2

Conclusion text
```

### MD022: Blank Lines Around Headings

Headings must be surrounded by blank lines.

```markdown
<!-- Wrong -->
Some text
## Heading
More text

<!-- Correct -->
Some text

## Heading

More text
```

### MD033: Inline HTML

Inline HTML is restricted. Generic types must be wrapped in backticks to avoid being interpreted as HTML tags.

```markdown
<!-- Wrong - triggers MD033 -->
Use ArrayPool<T> for buffer pooling.

<!-- Correct -->
Use `ArrayPool<T>` for buffer pooling.
```

## Disabled Rules

### MD013: Line Length

Disabled because agent templates contain long tool lists and descriptions that are more readable on single lines.

### MD060: Table Column Style

Disabled because tables render correctly regardless of spacing style.

## Code Block Language Reference

Use the appropriate language identifier for syntax highlighting:

| Content Type | Language Identifier |
|--------------|---------------------|
| C# code | `csharp` |
| PowerShell scripts | `powershell` |
| Bash/Shell commands | `bash` |
| JSON data | `json` |
| YAML configuration | `yaml` |
| Markdown examples | `markdown` |
| Plain text/pseudo-code | `text` |
| SQL queries | `sql` |
| XML/HTML | `xml` or `html` |
| JavaScript | `javascript` |
| TypeScript | `typescript` |
| Python | `python` |

## Common Patterns

### Memory Protocol Code Blocks

```markdown
` ` `text
mcp__cloudmcp-manager__memory-search_nodes with query="[topic]"
mcp__cloudmcp-manager__memory-open_nodes for specific entities
` ` `
```

### Workflow Diagrams

```markdown
` ` `text
analyst -> architect -> planner -> critic -> implementer -> qa
` ` `
```

### Checklist Examples

```markdown
` ` `markdown
- [ ] Task 1
- [ ] Task 2
- [x] Completed task
` ` `
```

### Commit Message Examples

```markdown
` ` `text
<type>(<scope>): <description>

<optional body>
` ` `
```

## Generic Type Escaping

When documenting .NET generic types, always wrap them in backticks:

| Raw Text | Formatted |
|----------|-----------|
| `ArrayPool<T>` | Buffer pooling |
| `Span<T>` | Memory spans |
| `IEnumerable<T>` | Collections |
| `Dictionary<TKey, TValue>` | Key-value storage |
| `Task<T>` | Async results |
| `Func<T, TResult>` | Function delegates |

## Pre-commit Hook (Optional)

To run linting automatically before commits, install pre-commit:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.20.0
    hooks:
      - id: markdownlint-cli2
```

## Excluded Directories

The following directories are excluded from linting:

- `node_modules/` - Third-party dependencies
- `.agents/` - Generated agent artifacts (ADRs, plans, etc.)

## Troubleshooting

### "Fenced code blocks should have a language specified"

Add a language identifier after the opening fence:

```markdown
` ` `text
Your content here
` ` `
```

### "Inline HTML" on generic types

Wrap the generic type in backticks:

```markdown
Use `List<T>` instead of arrays.
```

### "Lists should be surrounded by blank lines"

Add a blank line before and after the list.

## References

- [markdownlint Rules Documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [markdownlint-cli2 Configuration](https://github.com/DavidAnson/markdownlint-cli2#configuration)
