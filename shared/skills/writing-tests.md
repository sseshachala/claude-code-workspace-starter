---
name: writing-tests
description: TDD-first skill — write the failing test before the implementation, covering happy path, error paths, and boundary conditions
---

# Writing Tests Skill

## Test-First Mandate
1. Write the failing test before writing any implementation code
2. Run the test — confirm it fails for the right reason
3. Write the minimum code to make it pass
4. Refactor if needed, keeping tests green

## Test Naming Convention
```
it('should [expected behavior] when [condition]')
```

Examples:
- `it('should return 404 when user does not exist')`
- `it('should reject payment when card is expired')`
- `it('should handle empty array without throwing')`

## Coverage Per Function (minimum)
- **Happy path**: valid input, expected output
- **Error path**: invalid input, missing data, upstream failure
- **Boundary**: empty string, zero, max value, null, undefined

## What Not to Mock
- Only mock what you don't own (third-party APIs, external services)
- Never mock your own code's internals — that tests the mock, not the code
- Use real DB with test data for integration tests (not in-memory fakes)
- Use `nock` / `httpretty` / `responses` for HTTP calls to external APIs

## Framework-Specific Patterns

### Node.js / TypeScript (Vitest / Jest)
```ts
describe('UserService', () => {
  it('should throw NotFoundError when user does not exist', async () => {
    await expect(userService.getById('nonexistent')).rejects.toThrow(NotFoundError)
  })
})
```

### Python (pytest)
```python
def test_returns_404_when_user_missing(client):
    response = client.get('/api/users/nonexistent')
    assert response.status_code == 404
```

## Before Marking Tests Complete
- Run the full test suite: `npm test` / `pytest` / `go test ./...`
- Confirm no existing tests broke
- Check coverage hasn't dropped below threshold
