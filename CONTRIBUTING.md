# Contributing to Task Manager

First off, thank you for considering contributing to Task Manager! It's people like you that make this project such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inspiring community for all.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots and animated GIFs if possible**
* **Include your environment details** (Elixir version, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior and explain the behavior you'd like to see**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the Elixir style guide
* Include thoughtfully-worded, well-structured tests
* Document new code based on the Documentation Styleguide
* End all files with a newline
* Maintain test coverage above 90%

## Development Process

### Setting Up Your Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR-USERNAME/elixir-ci-pipeline-demo.git
   cd elixir-ci-pipeline-demo
   ```

3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/codeforgood-org/elixir-ci-pipeline-demo.git
   ```

4. Install dependencies:
   ```bash
   mix deps.get
   cd assets && npm install && cd ..
   ```

5. Set up the database:
   ```bash
   mix ecto.setup
   ```

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Add some feature"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/my-new-feature
   ```

4. Create a Pull Request

### Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (formatting, etc.)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to build process or auxiliary tools

**Examples:**
```
feat(tasks): add task filtering by status

Add ability to filter tasks by their status in the API endpoint.
This includes query parameter support and tests.

Closes #123
```

```
fix(api): correct validation error response format

The error response was not following the documented format.
Updated to match API documentation.
```

### Code Style

We use the following tools to maintain code quality:

#### Formatting
```bash
# Check formatting
mix format --check-formatted

# Fix formatting
mix format
```

#### Credo (Style Guide)
```bash
# Run Credo
mix credo --strict

# Show all issues including low priority
mix credo --all
```

#### Dialyzer (Type Checking)
```bash
# Run Dialyzer
mix dialyzer
```

#### Sobelow (Security)
```bash
# Run security scan
mix sobelow --config
```

### Testing

All code contributions must include tests:

```bash
# Run tests
mix test

# Run tests with coverage
mix coveralls

# Run tests with HTML coverage report
mix coveralls.html
```

**Testing Guidelines:**
- Write tests for all new features
- Update tests when modifying existing features
- Ensure all tests pass before submitting PR
- Maintain test coverage above 90%
- Use descriptive test names
- Follow the AAA pattern (Arrange, Act, Assert)

**Example Test:**
```elixir
test "create_task/1 with valid data creates a task" do
  # Arrange
  attrs = %{title: "Test Task", priority: "high"}

  # Act
  assert {:ok, task} = Tasks.create_task(attrs)

  # Assert
  assert task.title == "Test Task"
  assert task.priority == "high"
end
```

### Documentation

* Use ExDoc format for module and function documentation
* Include examples in function documentation
* Update README.md if adding new features
* Update API.md for API changes

**Example:**
```elixir
@doc """
Creates a task.

## Examples

    iex> create_task(%{title: "My Task"})
    {:ok, %Task{}}

    iex> create_task(%{title: nil})
    {:error, %Ecto.Changeset{}}

"""
def create_task(attrs \\ %{})
```

## Project Structure

Understanding the project structure will help you contribute:

```
lib/
├── task_manager/           # Business logic layer
│   ├── tasks/              # Tasks domain
│   │   └── task.ex        # Task schema
│   └── tasks.ex           # Tasks context (business logic)
├── task_manager_web/      # Web layer
│   ├── controllers/       # API controllers
│   ├── components/        # Reusable components
│   └── router.ex          # Route definitions
```

## Review Process

1. **Automated Checks**: All PRs must pass CI checks
   - Tests must pass
   - Code coverage must be maintained
   - Credo checks must pass
   - Dialyzer must pass
   - Sobelow security scan must pass

2. **Code Review**: At least one maintainer will review your PR
   - Code quality and style
   - Test coverage and quality
   - Documentation completeness
   - Adherence to project standards

3. **Feedback**: Address any requested changes
   - Push new commits to your branch
   - Do not force-push after review has started
   - Respond to comments

4. **Merge**: Once approved, a maintainer will merge your PR

## Release Process

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

## Getting Help

* Check the [README.md](README.md) for setup and usage information
* Check the [API.md](API.md) for API documentation
* Search existing GitHub issues
* Ask questions in GitHub Discussions
* Reach out to maintainers

## Recognition

Contributors will be recognized in:
- The project README
- Release notes
- The GitHub contributors page

## Additional Resources

* [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
* [Phoenix Framework Guides](https://hexdocs.pm/phoenix/overview.html)
* [Ecto Documentation](https://hexdocs.pm/ecto/Ecto.html)
* [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Task Manager! 🎉
